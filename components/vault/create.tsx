import {useState} from "react";
import {Vault} from "bsafe";
import {BoxExample} from "../box-example";

const CreateVault = () => {
    const [vault, setVault] = useState<Vault | null>(null)

    const createVault = () => {
        const vaultInstance = new Vault({
            configurable: {
                network: 'https://beta-3.fuel.network/graphql',
                SIGNATURES_COUNT: 1,
                SIGNERS: ['fuel1ztr6nkwh5ld5emlzduwf8djt3xl8yydvape5d3jznj4q8w7ex26sy54nfh'],
                HASH_PREDUCATE: undefined,
            }
        })

        setVault(vaultInstance);
    }

    return (
        <BoxExample>
            <div>{vault?.address.toAddress()}</div>
            <button
                style={{
                    backgroundColor: '#57d57d',
                    color: 'rgba(16,44,24)',
                    padding: '5px 10px',
                    marginTop: 5
            }}
                onClick={createVault}
                disabled={vault}
            >
                Create vault
            </button>
        </BoxExample>
    )
}

export {CreateVault}
