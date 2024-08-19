use std::string::ToString;
use fuels::prelude::{Contract, CreateTransactionBuilder, LoadConfiguration, Provider};

/// The API token to connect to Bako Gateway
/// Generate at https://safe.bako.global/ in the vault setting
const API_TOKEN: String = "".to_string();
const BAKO_GATEWAY_URL: String = "https://api.bako.global/v1/graphql?api_token=".to_string();

#[tokio::main]
async fn main() {
    // Connect to Bako Gateway with the API token
    let provider = Provider::connect(format!("{BAKO_GATEWAY_URL}{api_token}")).await?;

    // Load the contract from the binary file
    let contract = Contract::load_from(
        "../contracts/contract/out/release/contract.bin",
        LoadConfiguration::default(),
    )?;

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
    ).with_max_fee_estimation_tolerance(0.05);

    let transaction = transaction_builder.build(provider).await?;

    // Send the transaction to Bako
    println!("Sending tx to Bako...");
    let tx_id = provider.send_transaction(transaction).await?;

    println!("Transaction sent to Bako!");
    println!("- Contract ID: {}", contract_id);
    println!("- Transaction ID: {}", tx_id.to_string());
}
