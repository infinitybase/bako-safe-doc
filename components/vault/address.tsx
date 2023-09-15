import {Example} from "../example";
import {useVault} from "../../hooks";

const VaultAddress = () => {
    const {create, vault} = useVault();

    return (
        <Example.Container>
            <Example.Box>
                {vault && (
                    <>
                        Vault address:{' '}
                        <Example.Text as="b">
                            {vault?.address.toAddress()}
                        </Example.Text>
                    </>
                )}
            </Example.Box>
            <Example.Button
                onClick={create}
                disabled={vault}
            >
                Get address
            </Example.Button>
        </Example.Container>
    )
}

export {VaultAddress}
