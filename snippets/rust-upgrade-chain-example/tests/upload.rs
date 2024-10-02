use fuel_tx::field::{SubsectionIndex, SubsectionsNumber};
use fuel_tx::{Bytes32, Upgrade, Upload};
use fuels::client::FuelClient;
use fuels::crypto::SecretKey;
use fuels::prelude::*;
use std::hash::Hash;
use std::ops::Add;
use std::str::FromStr;

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: &str = "7b461dc46264421ad244ba5d9db551d45408dd3c698d6865980b8ef57b65908bfb9e2d00ec87dff86573b4388d65ad84ff2e5e548b97e4df2d0eb3f456c8e0115d8eedd6b4242b638496dae319b18c68";

/// Bako Gateway url
const BAKO_GATEWAY_URL: &str = "https://api.bako.global/v1/graphql?api_token=";

/// Target node url
const FUEL_NODE_URL: &str = "=";

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
    let provider = Provider::connect(bako_node_url).await?;

    // Send upgrade transaction to the Bako Gateway
    transaction_upgrade_state(root, provider).await?;

    Ok(())
}

async fn transaction_upgrade_state(root: Bytes32, provider: Provider) -> Result<()> {
    let mut builder =
        UpgradeTransactionBuilder::prepare_state_transition_upgrade(root, TxPolicies::default());
    let client = FuelClient::new(provider.url()).unwrap();

    let transaction = builder.build(provider).await?;

    let upgrade: Upgrade = transaction.into();
    let tx_result = client.submit(&upgrade.clone().into()).await;

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
        max_fee = max_fee.add(10000);

        wallet.adjust_for_fee(&mut builder, max_fee).await?;

        let transaction = builder
            .with_tx_policies(TxPolicies::default().with_max_fee(max_fee))
            .build(provider.clone())
            .await?;

        let upload: Upload = transaction.into();

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
