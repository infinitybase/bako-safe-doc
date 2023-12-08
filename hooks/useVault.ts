import {Vault} from "bsafe";
import {useMemo, useState} from "react";
import {useFuel} from "./fuel";
import {CoinQuantity} from "@fuel-ts/providers";
import {bn} from "fuels";

const useVault = () => {
    const [fuel] = useFuel();

    const [vault, setVault] = useState<Vault | null>(null)
    const [assets, setAssets] = useState<CoinQuantity[]>([])
    const [balance, setBalance] = useState('')

    const hasBalance = useMemo(() => {
        return bn(bn.parseUnits(balance)).gt(bn.parseUnits('0.000000001'));
    }, [balance]);

    const create = async () => {
        const provider = await fuel.getProvider();
        const vaultInstance = await Vault.create({
            name: 'Vault by doc',
            description: 'Vault created in doc',
            provider: provider,
            configurable: {
                chainId: provider.getChainId(),
                network: provider.url,
                SIGNATURES_COUNT: 1,
                SIGNERS: ['fuel1ztr6nkwh5ld5emlzduwf8djt3xl8yydvape5d3jznj4q8w7ex26sy54nfh'],
            },
        });

        setVault(vaultInstance);
    }

    const findBalance = async () => {
        const balance = await vault.getBalance();
        setBalance(balance.format())
    }

    const sendBalance = async () => {
        try {
            const isConnected = await fuel.isConnected();

            if (!isConnected) return;

            const account = await fuel.currentAccount();
            const wallet = await fuel.getWallet(account);

            await wallet.transfer(vault.address, bn(bn.parseUnits('0.0001')));
        } catch (e) {
            console.log(e)
        }
    }

    const findAssets = async () => {
        const assets = await vault.getBalances();
        setAssets(assets);
    }

    return {
        vault,
        assets,
        balance,
        hasBalance,
        create,
        findAssets,
        findBalance,
        sendBalance,
    }
}

export {useVault}
