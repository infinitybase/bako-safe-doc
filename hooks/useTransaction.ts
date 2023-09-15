import {IVaultTransfer, Vault} from "bsafe";
import {bn} from "fuels";
import {useState} from "react";
import {useFuel} from "./fuel";

const NativeAssetId =
    '0x0000000000000000000000000000000000000000000000000000000000000000';

const useTransaction = (vault?: Vault) => {
    const [fuel] = useFuel();
    const [transactionInstance, setTransactionInstance] = useState<IVaultTransfer | null>(null)
    const [isSigned, setIsSigned] = useState(false)
    const [isSending, setIsSending] = useState(false)
    const [transactionResponse, setTransactionResponse] = useState<{ link: string, gasUsed: string } | null>(null)

    const instanceTransaction = async () => {
        const transfer = await vault!.includeTransaction([
            {
                amount: bn(bn.parseUnits('0.00001')).format(),
                assetId: NativeAssetId,
                to: vault!.getConfigurable().SIGNERS[0]
            }
        ], []);

        setTransactionInstance(transfer);

        return transfer;
    }

    const signTransaction = async () => {
        try {
            const transfer = await instanceTransaction();
            const account = await fuel.currentAccount();
            const wallet = await fuel.getWallet(account);
            const signature = await wallet.signMessage(transfer.transaction.getHashTxId());

            transfer.transaction.witnesses = [signature]

            setTransactionInstance(transfer);
            setIsSigned(true);

            return transfer;
        } catch (e) {
            console.log(e)
        }
    }

    const sendTransaction = async () => {
        try {
            setIsSending(true);
            const transfer = await signTransaction();
            const transactionResponse = await transfer.transaction.sendTransaction();

            setTransactionResponse({
                gasUsed: transactionResponse.gasUsed,
                link: transactionResponse.block,
            })
        } catch (e) {
            console.log(e)
        } finally {
            setIsSending(false)
        }
    }


    return {
        isSigned,
        isSending,
        transactionResponse,
        transactionInstance,
        instanceTransaction,
        signTransaction,
        sendTransaction
    }
}

export {useTransaction};
