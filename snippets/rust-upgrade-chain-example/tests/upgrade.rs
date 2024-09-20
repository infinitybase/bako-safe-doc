use fuel_tx::Transaction;
use fuels::client::FuelClient;
use fuels::crypto::SecretKey;
use fuels::prelude::*;
use fuels::tx::GasCosts;
use std::hash::Hash;
use std::str::FromStr;

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: &str = "";
const BAKO_GATEWAY_URL: &str = "https://api.bako.global/v1/graphql?api_token=";
const FUEL_NODE_URL: &str = "";

#[tokio::test]
async fn test_upgrade_tx() -> Result<()> {
    // Connect to Bako Gateway with the API token
    let mut wallet = WalletUnlocked::new_from_private_key(
        SecretKey::from_str("a449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298")?,
        None,
    );

    let amount = 60_000;

    let node_url = format!("{FUEL_NODE_URL}");
    let provider = Provider::connect(node_url.clone()).await?;
    wallet.set_provider(provider.clone());

    // Get consensus parameters and upgrade the gas costs
    let mut new_consensus_parameters = provider.chain_info().await?.consensus_parameters;
    new_consensus_parameters.set_gas_costs(GasCosts::free());

    // Prepare the upgrade transaction with the new consensus parameters
    let mut builder = UpgradeTransactionBuilder::prepare_consensus_parameters_upgrade(
        &new_consensus_parameters,
        TxPolicies::default().with_max_fee(amount),
    );
    let base_asset_id = provider.base_asset_id();
    let inputs = wallet
        .get_asset_inputs_for_amount(*base_asset_id, amount, None)
        .await?;
    let outputs = wallet.get_asset_outputs_for_amount(wallet.address(), *base_asset_id, amount);

    builder.add_signer(wallet.clone())?;

    let tx = builder
        .with_inputs(inputs)
        .with_outputs(outputs)
        .build(provider.clone())
        .await?;

    let tx_upgrade = Transaction::from(tx);

    // Send the transaction to the Bako Gateway
    let node_url = format!("{BAKO_GATEWAY_URL}{API_TOKEN}");
    let client = FuelClient::new(node_url).unwrap();
    let tx_id = client.submit(&tx_upgrade).await?;

    println!("Transaction: {:?}", tx_id);

    Ok(())
}
