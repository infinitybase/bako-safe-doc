use fuel_tx::Transaction;
use fuels::client::FuelClient;
use fuels::crypto::SecretKey;
use fuels::prelude::*;
use fuels::tx::GasCosts;
use std::hash::Hash;
use std::str::FromStr;

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: &str = "ed8caa7e41699a1442ff4cd39a5802670f7bb31b86332bc06dbf60f1c35e3aca9fce1d7c37757c42b8fa14bf3dedb4cfde79a64cee0a5de0a57cd387918a24d531890e79ac2c8430448c3f2c39c5ae67";
// const BAKO_GATEWAY_URL: &str = "https://api.bako.global/v1/graphql?api_token=";
const BAKO_GATEWAY_URL: &str = "http://localhost:4444/v1/graphql?api_token=";
const FUEL_NODE_URL: &str = "http://localhost:4000/v1/graphql";

#[tokio::test]
async fn test_upgrade_tx() -> Result<()> {
    let mut wallet = WalletUnlocked::new_from_private_key(
        SecretKey::from_str("a449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298")?,
        None,
    );

    // Connect to Bako Gateway with the API token
    let node_url = format!("{BAKO_GATEWAY_URL}{API_TOKEN}");
    let provider = Provider::connect(node_url.clone()).await?;
    wallet.set_provider(provider.clone());

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
