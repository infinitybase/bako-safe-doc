import {useVault} from "../../hooks";
import {useEffect} from "react";
import {Example} from "../example";
import {IsConnected} from "../fuel/IsConnected";
import {useTransaction} from "../../hooks/useTransaction";

const InstanceTransaction = () => {
    const {create, vault, balance, hasBalance, sendBalance, findBalance} = useVault();
    const {transactionInstance, instanceTransaction} = useTransaction(vault);

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
            <Example.Box>
                {transactionInstance && (
                    <>
                        Transcation hash:{' '}
                        <Example.Text as="b">
                            {transactionInstance.hash}
                        </Example.Text>
                    </>
                )}
            </Example.Box>
            <Example.Box style={{ display: 'flex', gap: 10 }}>
                {!hasBalance && (
                    <Example.Button onClick={sendBalance}>
                        Send balance
                    </Example.Button>
                )}
                {!hasBalance && (
                    <Example.Button onClick={findBalance}>
                        Get balance
                    </Example.Button>
                )}
                {hasBalance && (
                    <Example.Button onClick={instanceTransaction}>
                        Instance transaction
                    </Example.Button>
                )}
            </Example.Box>
            <IsConnected />
        </Example.Container>
    )
}

export {InstanceTransaction}
