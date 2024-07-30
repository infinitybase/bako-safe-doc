library;

use std::string::String;
use standards::src5::State;

pub struct ConstructorInput {
    /// The name of the collection.
    pub name: String,

    /// The description of the collection.
    pub description: Option<String>,
}

pub struct CollectionInitializedEvent {
    /// The ID of the collection.
    pub id: ContractId,

    /// The owner of the collection.
    pub owner: Identity,
}

abi Constructor {
    /// Initializes the contract with the given input.
    ///
    /// # Arguments
    ///
    /// * `input`: [ConstructorInput] - The input to initialize the contract with.
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn foo(contract_id: ContractId) {
    ///     let input = ConstructorInput {
    ///         owner: Identity::caller(),
    ///         name: String::from_ascii_str("My Collection"),
    ///         symbol: String::from_ascii_str("MC"),
    ///         description: Some(String::from_ascii_str("This is my collection")),
    ///     };
    ///
    ///     let constructor_abi = abi(Constructor, contract_id);
    ///     constructor_abi.constructor(input);
    /// }
    /// ```
    #[storage(write)]
    fn constructor(input: ConstructorInput);
}

abi Info {
    #[storage(read)]
    fn collection_owner() -> Identity;

    /// Returns the name of the collection.
    ///
    /// # Return Values
    ///
    /// * [String] - The name of the collection.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn foo(contract_id: ContractId) {
    ///     let constructor_abi = abi(Info, contract_id);
    ///     constructor_abi.collection_name();
    /// }
    /// ```
    #[storage(read)]
    fn collection_name() -> String;

    /// Returns the description of the collection.
    ///
    /// # Return Values
    ///
    /// * [Option<String>] - The description of the collection.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn foo(contract_id: ContractId) {
    ///     let constructor_abi = abi(Info, contract_id);
    ///     constructor_abi.collection_description();
    /// }
    /// ```
    #[storage(read)]
    fn collection_description() -> Option<String>;
}

pub struct CollectionItemInput {
    /// The name of the item.
    pub name: String,

    /// The image of the item.
    pub image: String,

    /// The description of the item.
    pub description: Option<String>,
}

pub struct CollectionItemMintedEvent {
    /// The ID of the item.
    pub asset_id: AssetId,

    /// The owner of the item.
    pub owner: Identity,
}

pub enum CollectionItemError {
    /// Emitted when the item is already minted.
    AlreadyMinted: (),
}

abi CollectionManager {
    /// Adds an item to the collection.
    ///
    /// # Arguments
    ///
    /// * `input`: [CollectionItemInput] - The input to add an item to the collection.
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn foo(contract_id: ContractId) {
    ///     let input = CollectionItemInput {
    ///         name: String::from_ascii_str("My Item"),
    ///         image: String::from_ascii_str("https://example.com/image.png"),
    ///         description: Some(String::from_ascii_str("This is my item")),
    ///     };
    ///
    ///     let constructor_abi = abi(CollectionManager, contract_id);
    ///     constructor_abi.add_item(input);
    /// }
    /// ```
    #[storage(read, write)]
    fn add_item(input: CollectionItemInput);

    /// Get all assets of the collection.
    ///
    /// # Returns
    ///
    /// * [Vec<AssetId>] - The list of all assets of the collection.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn foo(contract_id: ContractId) {
    ///     let constructor_abi = abi(CollectionManager, contract_id);
    ///     constructor_abi.all_assets();
    /// }
    /// ```
    #[storage(read)]
    fn all_assets() -> Vec<AssetId>;
}