import {useVault} from "../../hooks";
import {useEffect} from "react";
import {Example} from "../example";
import {IsConnected} from "../fuel/IsConnected";
import {useTransaction} from "../../hooks/useTransaction";
import {bn} from "fuels";

const SendTransaction = () => {
    const {create, vault, balance, hasBalance, sendBalance, findBalance} = useVault();
    const {transactionResponse, sendTransaction, isSending} = useTransaction(vault);

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
                {transactionResponse && (
                    <>
                        <Example.Box>
                            Gas fee:{' '}
                            <Example.Text as="b">
                                {transactionResponse.gasUsed} ETH
                            </Example.Text>
                        </Example.Box>
                        <Example.Box>
                            Block explorer link:{' '}
                            <Example.Text
                                as="a"
                                target="_blank"
                                href={transactionResponse.link}
                                style={{
                                    color: '#57d57d',
                                    cursor: 'pointer'
                                }}
                            >
                                Block explorer
                            </Example.Text>
                        </Example.Box>
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
                    <Example.Button disabled={isSending} onClick={async () => {
                        await sendTransaction();
                        findBalance();
                    }}>
                        {isSending ? 'Sending...' : 'Send transaction'}
                    </Example.Button>
                )}
            </Example.Box>
            <IsConnected />
        </Example.Container>
    )
}

export {SendTransaction}
