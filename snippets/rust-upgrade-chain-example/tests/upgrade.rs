use fuel_tx::Transaction;
use fuels::client::FuelClient;
use fuels::prelude::*;
use fuels::tx::GasCosts;
use std::hash::Hash;

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: &str = "";

/// Bako Gateway url
const BAKO_GATEWAY_URL: &str = "https://api.bako.global/v1/graphql?api_token=";

/// Target node url
const FUEL_NODE_URL: &str = "";

#[tokio::test]
async fn test_upgrade_tx() -> Result<()> {
    // Connect to Bako Gateway with the API token
    let node_url = format!("{BAKO_GATEWAY_URL}{API_TOKEN}");
    let provider = Provider::connect(FUEL_NODE_URL).await?;

    // Get consensus parameters and upgrade the gas costs
    let mut new_consensus_parameters = provider.chain_info().await?.consensus_parameters;
    new_consensus_parameters.set_gas_costs(GasCosts::free());

    // Prepare the upgrade transaction with the new consensus parameters
    let mut builder = UpgradeTransactionBuilder::prepare_consensus_parameters_upgrade(
        &new_consensus_parameters,
        TxPolicies::default(),
    );
    let tx = builder.build(provider.clone()).await?;
    let tx_upgrade = Transaction::from(tx);

    // Send the transaction to the Bako Gateway
    let client = FuelClient::new(node_url).unwrap();
    let tx_id = client.submit(&tx_upgrade).await?;

    println!("Transaction: {:?}", tx_id);
    Ok(())
}
