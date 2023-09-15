import {useVault} from "../../hooks";
import {useEffect} from "react";
import {Example} from "../example";
import {IsConnected} from "../fuel/IsConnected";
import {useTransaction} from "../../hooks/useTransaction";
import {bn} from "fuels";

const SignTransaction = () => {
    const {create, vault, balance, hasBalance, sendBalance, findBalance} = useVault();
    const {transactionInstance, signTransaction, isSigned} = useTransaction(vault);

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
                {isSigned && (
                    <>
                        Signatures:{' '}
                        <Example.Text as="b">
                            {transactionInstance?.transaction.witnesses[0]}
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
                    <Example.Button onClick={signTransaction}>
                        Sign transaction
                    </Example.Button>
                )}
            </Example.Box>
            <IsConnected />
        </Example.Container>
    )
}

export {SignTransaction}
