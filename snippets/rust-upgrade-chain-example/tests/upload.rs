use fuel_tx::field::{SubsectionIndex, SubsectionsNumber};
use fuel_tx::policies::Policies;
use fuel_tx::{Bytes32, Chargeable, Input, Transaction, Upgrade, Upload};
use fuels::client::FuelClient;
use fuels::crypto::SecretKey;
use fuels::prelude::*;
use std::hash::Hash;
use std::ops::Add;
use std::str::FromStr;

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: &str = "ed8caa7e41699a1442ff4cd39a5802670f7bb31b86332bc06dbf60f1c35e3aca9fce1d7c37757c42b8fa14bf3dedb4cfde79a64cee0a5de0a57cd387918a24d531890e79ac2c8430448c3f2c39c5ae67";
const BAKO_GATEWAY_URL: &str = "http://localhost:4444/v1/graphql?api_token=";
const FUEL_NODE_URL: &str = "http://localhost:4000/v1/graphql";
const WASM_BYTECODE: &[u8] = include_bytes!("../local-testnet/fuel-core-wasm-executor.wasm");
const SUBSECTION_SIZE: usize = 192 * 1024;

#[tokio::test]
async fn test_upload_tx() -> Result<()> {
    // Connect to Bako Gateway with the API token
    let node_url = format!("{FUEL_NODE_URL}");
    let bako_node_url = format!("{BAKO_GATEWAY_URL}{API_TOKEN}");

    // Start the client with the Fuel Provider
    let client = FuelClient::new(node_url.clone()).unwrap();
    let provider = Provider::connect(node_url.clone()).await?;

    let mut wallet = WalletUnlocked::new_from_private_key(
        SecretKey::from_str("a449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298")?,
        Some(provider.clone()),
    );

    // Split the bytecode into subsections
    let subsections = UploadSubsection::split_bytecode(WASM_BYTECODE, SUBSECTION_SIZE).unwrap();
    let root = subsections[0].root;

    // Create transactions from the subsections
    transactions_from_subsections(subsections, wallet.clone(), client.clone()).await?;

    // Setup the client and provider for send to Bako
    let client = FuelClient::new(bako_node_url.clone()).unwrap();
    let provider = Provider::connect(bako_node_url).await?;
    wallet.set_provider(provider);

    // Send upgrade transaction to the Bako Gateway
    transaction_upgrade_state(root, wallet, client).await?;

    Ok(())
}

async fn transaction_upgrade_state(
    root: Bytes32,
    wallet: WalletUnlocked,
    client: FuelClient,
) -> Result<()> {
    let max_fee = 148300;

    let provider = wallet.provider().unwrap();
    let base_asset_id = provider.base_asset_id();
    let mut builder = UpgradeTransactionBuilder::prepare_state_transition_upgrade(
        root,
        TxPolicies::default().with_max_fee(max_fee),
    );

    builder.add_signer(wallet.clone())?;

    let inputs = wallet
        .get_asset_inputs_for_amount(*base_asset_id, max_fee, None)
        .await?;
    let outputs = wallet.get_asset_outputs_for_amount(wallet.address(), *base_asset_id, max_fee);

    wallet.adjust_for_fee(&mut builder, max_fee).await?;

    let transaction = builder
        .with_tx_policies(TxPolicies::default().with_max_fee(max_fee))
        .with_inputs(inputs)
        .with_outputs(outputs)
        .build(provider.clone())
        .await?;

    let upgrade: Upgrade = transaction.into();
    let tx_result = client.submit_and_await_commit(&upgrade.clone().into()).await;

    match tx_result {
        Ok(fuel_tx) => {
            println!("Transaction: {:?}", fuel_tx);
        }
        Err(_) => {
            println!("Transaction failed");
        }
    }

    Ok(())
}

async fn transactions_from_subsections(
    subsections: Vec<UploadSubsection>,
    wallet: WalletUnlocked,
    client: FuelClient,
) -> Result<()> {
    let provider = wallet.provider().unwrap();

    for subsection in subsections {
        let mut builder =
            UploadTransactionBuilder::prepare_subsection_upload(subsection, TxPolicies::default())
                .with_inputs(vec![])
                .with_outputs(vec![]);

        builder.add_signer(wallet.clone())?;

        let mut max_fee = builder.estimate_max_fee(provider.clone()).await?;
        max_fee = max_fee.add(1000);

        wallet.adjust_for_fee(&mut builder, max_fee).await?;

        let transaction = builder
            .with_tx_policies(TxPolicies::default().with_max_fee(max_fee))
            .build(provider.clone())
            .await?;

        let upload: Upload = transaction.into();
        let consensus = client.chain_info().await?.consensus_parameters;
        let gas_costs = consensus.gas_costs();

        let i = upload.gas_used_by_metadata(gas_costs);
        println!("Gas used by metadata: {:?}", i);

        client
            .submit_and_await_commit(&upload.clone().into())
            .await?;

        println!(
            "Transaction {:?}/{:?}",
            upload.subsection_index(),
            upload.subsections_number()
        );
    }

    Ok(())
}
