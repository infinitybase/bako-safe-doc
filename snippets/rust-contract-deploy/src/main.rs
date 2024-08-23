use fuel_tx::Transaction;
use fuels::client::FuelClient;
use fuels::prelude::{Contract, CreateTransactionBuilder, LoadConfiguration, Provider};
use std::string::ToString;

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: &str = "";
const BAKO_GATEWAY_URL: &str = "https://api.bako.global/v1/graphql?api_token=";

#[tokio::main]
async fn main() {
    // Connect to Bako Gateway with the API token
    let node_url = format!("{BAKO_GATEWAY_URL}{API_TOKEN}");
    let client = FuelClient::new(node_url.clone()).expect("Failed to create FuelClient");
    let provider = Provider::connect(node_url)
        .await
        .expect("Failed to connect to provider");

    // Load the contract from the binary file
    let contract = Contract::load_from(
        "../contracts/contract/out/release/contract.bin",
        LoadConfiguration::default(),
    )
    .expect("Failed to load contract");

    // Prepare the transaction for contract deployment
    let contract_id = contract.contract_id();
    let state_root = contract.state_root();
    let salt = contract.salt();
    let storage_slots = contract.storage_slots();
    let code = contract.code();

    let transaction_builder = CreateTransactionBuilder::prepare_contract_deployment(
        code,
        contract_id,
        state_root,
        salt,
        storage_slots.to_vec(),
        Default::default(),
    )
    .with_max_fee_estimation_tolerance(0.05);

    let transaction = transaction_builder
        .build(provider.clone())
        .await
        .expect("Failed to build transaction");
    let tx = Transaction::from(transaction);

    // Send the transaction to Bako
    println!("Sending tx to Bako...");

    let tx_id = client
        .submit(&tx)
        .await
        .expect("Failed to submit transaction");

    println!("Transaction sent to Bako!");
    println!("- Contract ID: {}", contract_id);
    println!("- Transaction ID: {}", tx_id.to_string());
}
