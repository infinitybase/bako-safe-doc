contract;

mod interface;
mod lib;

use standards::{
    src20::SRC20, 
    src3::SRC3, 
    src5::{SRC5, State}, 
    src7::{Metadata, SRC7},
};
use sway_libs::{
    asset::{
        base::{
            _name,
            _set_name,
            _set_symbol,
            _symbol,
            _total_assets,
            _total_supply,
            SetAssetAttributes,
        },
        metadata::*,
        supply::{
            _burn,
            _mint,
        },
    },
    pausable::{
        _is_paused,
        _pause,
        _unpause,
        Pausable,
        require_not_paused,
    },
};
use std::{
    hash::*, 
    storage::{
        storage_vec::*,
        storage_string::*,
    },  
    asset::mint_to,
    bytes::Bytes,
    string::String,
};
use interface::{
    Info,
    Constructor, 
    ConstructorInput,
    CollectionManager,
    CollectionItemInput,
    CollectionItemError,
    CollectionItemMintedEvent,
};
use lib::{
    only_owner,
    owner_identity,
    initialize_ownership,
    require_initialized_ownership,
    require_uninitialized_ownership,
};

configurable {
    IMAGE_KEY: str[9] = __to_str_array("image_uri"),
    DESCRIPTION_KEY: str[11] = __to_str_array("description"),
}

storage {
    /// The total number of unique assets minted by this contract.
    ///
    /// # Additional Information
    ///
    /// This is the number of NFTs that have been minted.
    total_assets: u64 = 0,
    /// The total number of coins minted for a particular asset.
    ///
    /// # Additional Information
    ///
    /// This should always be 1 for any asset as this is an NFT contract.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    /// The name associated with a particular asset.
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    /// The symbol associated with a particular asset.
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    /// The metadata associated with a particular asset.
    ///
    /// # Additional Information
    ///
    /// In this NFT contract, there is no metadata provided at compile time. All metadata
    /// is added by users and stored into storage.
    metadata: StorageMetadata = StorageMetadata {},

    /// # Collection store
    ///
    /// The owner in storage.
    owner: State = State::Uninitialized,

    /// The name of the collection.
    collection_name: StorageString = StorageString {},

    /// The description of the collection.
    collection_description: StorageString = StorageString {},

    /// The collection items.
    collection_items: StorageVec<AssetId> = StorageVec {},
}

impl Info for Contract {
    #[storage(read)]
    fn collection_owner() -> Identity {
        owner_identity(storage.owner)
    }

    /// Returns the name of the collection.
    ///
    /// # Returns
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
    fn collection_name() -> String {
        require_initialized_ownership(storage.owner);
        storage.collection_name.read_slice().unwrap()
    }

    /// Returns the description of the collection.
    ///
    /// # Returns
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
    fn collection_description() -> Option<String> {
        require_initialized_ownership(storage.owner);
        storage.collection_description.read_slice()
    }
}

impl Constructor for Contract {
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
    ///         name: String::from("My Collection"),
    ///         symbol: String::from("MC"),
    ///         description: Some(String::from("This is my collection")),
    ///     };
    ///
    ///     let constructor_abi = abi(Constructor, contract_id);
    ///     constructor_abi.constructor(input);
    /// }
    /// ```
    #[storage(write)]
    fn constructor(input: ConstructorInput) {
        initialize_ownership(storage.owner);
        storage.collection_name.write_slice(input.name);

        if let Some(description) = input.description {
            storage.collection_description.write_slice(description);
        }
    }
}

impl CollectionManager for Contract {
    /// Adds a new item to the collection.
    ///
    /// # Arguments
    ///
    /// * `input`: [CollectionItemInput] - The input to add a new item to the collection.
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let input = CollectionItemInput {
    ///         asset,
    ///     };
    ///
    ///     let collection_manager_abi = abi(CollectionManager, contract_id);
    ///     collection_manager_abi.add_item(input);
    /// }
    /// ```
    #[storage(read, write)]
    fn add_item(input: CollectionItemInput) {
        // Ensure that the caller is the owner of the contract.
        only_owner(storage.owner);

        // Ensure that the asset has not already been minted.
        let sub_id = sha256(storage.total_assets.read());
        let owner = owner_identity(storage.owner);
        let asset = AssetId::new(
            ContractId::this(), 
            sha256(storage.total_assets.read())
        );

        require(
            storage
                .total_supply
                .get(asset)
                .try_read()
                .is_none(),
            CollectionItemError::AlreadyMinted,
        );

        // Mint the NFT
        let asset = _mint(
            storage
                .total_assets,
            storage
                .total_supply,
            Identity::ContractId(ContractId::this()),
            sub_id,
            1,
        );

        // Set the name of the asset.
        _set_name(storage.name, asset, input.name);

        // Set the image of the asset.
        _set_metadata(
            storage.metadata, 
            asset, 
            String::from_ascii_str(from_str_array(IMAGE_KEY)), 
            Metadata::String(input.image)
        );

        // Set the description of the collection.
        if let Some(description) = input.description {
            _set_metadata(
                storage.metadata, 
                asset, 
                String::from_ascii_str(from_str_array(DESCRIPTION_KEY)), 
                Metadata::String(description)
            );
        }

        // Add the asset to the collection.
        log(storage.collection_items.len());
        storage.collection_items.push(asset);

        log(CollectionItemMintedEvent {
            asset_id: asset,
            owner,
        });
    }

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
    fn all_assets() -> Vec<AssetId> {
        storage.collection_items.load_vec()
    }
}

impl SRC5 for Contract {
    /// Returns the owner.
    ///
    /// # Return Values
    ///
    /// * [State] - Represents the state of ownership for this contract.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src5::SRC5;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let ownership_abi = abi(contract_id, SRC_5);
    ///
    ///     match ownership_abi.owner() {
    ///         State::Uninitalized => log("The ownership is uninitalized"),
    ///         _ => log("This example will never reach this statement"),
    ///     }
    /// }
    /// ```
    #[storage(read)]
    fn owner() -> State {
        storage.owner.read()
    }
}

impl SRC20 for Contract {
    /// Returns the total number of individual NFTs for this contract.
    ///
    /// # Returns
    ///
    /// * [u64] - The number of assets that this contract has minted.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC20, contract_id);
    ///     let total_assets = contract_abi.total_assets();
    ///     assert(total_assets != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_assets() -> u64 {
        _total_assets(storage.total_assets)
    }

    /// Returns the total supply of coins for an asset.
    ///
    /// # Additional Information
    ///
    /// This must always be at most 1 for NFTs.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the total supply.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - The total supply of coins for `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract_id);
    ///     let total_supply = contract_abi.total_supply(asset).unwrap();
    ///     assert(total_supply == 1);
    /// }
    /// ```
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        _total_supply(storage.total_supply, asset)
    }

    /// Returns the name of the asset, such as “Ether”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the name.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The name of `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract_ic: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract_id);
    ///     let name = contract_abi.name(asset).unwrap();
    ///     assert(name.len() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        _name(storage.name, asset)
    }
    /// Returns the symbol of the asset, such as “ETH”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the symbol.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The symbol of `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract_id);
    ///     let symbol = contract_abi.symbol(asset).unwrap();
    ///     assert(symbol.len() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        _symbol(storage.symbol, asset)
    }
    /// Returns the number of decimals the asset uses.
    ///
    /// # Additional Information
    ///
    /// The standardized decimals for NFTs is 0u8.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the decimals.
    ///
    /// # Returns
    ///
    /// * [Option<u8>] - The decimal precision used by `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId, asset: AssedId) {
    ///     let contract_abi = abi(SRC20, contract_id);
    ///     let decimals = contract_abi.decimals(asset).unwrap();
    ///     assert(decimals == 0u8);
    /// }
    /// ```
    #[storage(read)]
    fn decimals(_asset: AssetId) -> Option<u8> {
        Some(0u8)
    }
}

impl SRC7 for Contract {
    /// Returns metadata for the corresponding `asset` and `key`.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the metadata.
    /// * `key`: [String] - The key to the specific metadata.
    ///
    /// # Returns
    ///
    /// * [Option<Metadata>] - `Some` metadata that corresponds to the `key` or `None`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src_7::{SRC7, Metadata};
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC7, contract_id);
    ///     let key = String::from_ascii_str("image");
    ///     let data = contract_abi.metadata(asset, key);
    ///     assert(data.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        storage.metadata.get(asset, key)
    }
}