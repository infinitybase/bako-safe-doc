import {Example} from "../example";
import {useVault} from "../../hooks";
import {useEffect} from "react";
import {IsConnected} from "../fuel/IsConnected";

const VaultBalance = () => {
    const {create, balance, findBalance, sendBalance} = useVault();

    useEffect(() => {
        create();
    }, []);

    return (
        <Example.Container>
            <Example.Box>
                {balance && (
                    <>
                        Vault balance:{' '}
                        <Example.Text as="b">
                            {balance} ETH
                        </Example.Text>
                    </>
                )}
            </Example.Box>
            <Example.Box style={{ display: 'flex', gap: 10 }}>
                <Example.Button onClick={findBalance}>
                    Get balance
                </Example.Button>
                <Example.Button onClick={sendBalance}>
                    Send balance
                </Example.Button>
            </Example.Box>
            <IsConnected />
        </Example.Container>
    )
}

export {VaultBalance}
