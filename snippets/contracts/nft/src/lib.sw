library;

use standards::src5::State;

/// Error log for when access is denied.
pub enum AccessError {
    /// Emitted when the caller is not the owner of the contract.
    NotOwner: (),

    /// Emitted when the ownership is initialized.
    AlreadyInitialized: (),

    /// Emitted when the ownership is not initialized.
    NotInitialized: (),
}

pub struct Ownership {}

#[storage(read)]
pub fn only_owner(state: StorageKey<State>) {
    match state.read() {
        State::Initialized(owner) => require(
            owner == msg_sender().unwrap(),
            AccessError::NotOwner
        ),
        _ => require(false, AccessError::NotOwner),
    }
}

/// Returns the owner of the contract.
#[storage(read)]
pub fn owner_identity(state: StorageKey<State>) -> Identity {
    match state.read() {
        State::Initialized(owner) => owner,
        _ => {
            log(AccessError::NotInitialized);
            revert(0);
        }
    }
}

// Require the ownership not to be initialized.
#[storage(read)]
pub fn require_uninitialized_ownership(state: StorageKey<State>) {
    match state.read() {
        State::Uninitialized => (),
        _ => require(false, AccessError::AlreadyInitialized),
    }
}

// Require the ownership to be initialized.
#[storage(read)]
pub fn require_initialized_ownership(state: StorageKey<State>) {
    match state.read() {
        State::Initialized => (),
        _ => require(false, AccessError::NotInitialized),
    }
}

/// Initializes the ownership of the contract.
#[storage(read, write)]
pub fn initialize_ownership(state: StorageKey<State>) {
    require_uninitialized_ownership(state);
    state.write(
        State::Initialized(
            msg_sender().unwrap()
        )
    );
}

// impl StorageKey<State> {
//     /// Returns the owner of the contract.
//     #[storage(read)]
//     pub fn identity(self) -> Identity {
//         match self.read() {
//             State::Initialized(owner) => owner,
//             _ => revert(0),
//         }
//     }

//     /// Initializes the ownership of the contract.
//     #[storage(read, write)]
//     pub fn initialize(self) {
//         self.require_uninitialized();
//         self.write(
//             State::Initialized(
//                 msg_sender().unwrap()
//             )
//         );
//     }

//     // Require the ownership not to be initialized.
//     #[storage(read)]
//     pub fn require_uninitialized(self) {
//         match self.read() {
//             State::Uninitialized => (),
//             _ => require(false, AccessError::AlreadyInitialized),
//         }
//     }

//     /// Checks if the caller is the owner of the contract.
//     #[storage(read)]
//     pub fn only_owner(self) {
//         match self.read() {
//             State::Initialized(owner) => require(
//                 owner == msg_sender().unwrap(),
//                 AccessError::NotOwner
//             ),
//             _ => revert(0),
//         }
//     }


//     /// Transfer ownership of the contract to a new address.
//     #[storage(read, write)]
//     pub fn transfer_ownership(self, new_owner: Identity) {
//         self.only_owner();
//         self.write(State::Initialized(new_owner));
//     }
// }