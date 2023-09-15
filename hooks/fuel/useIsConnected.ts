import {useFuel} from "./useFuel";
import {useEffect, useState} from "react";

const useIsConnected = () => {
    const [fuel] = useFuel();

    const [account, setAccount] = useState('')
    const [isConnected, setIsConnected] = useState(false)
    const [isConnecting, setIsConnecting] = useState(false)

    const handleConnect = async () => {
        setIsConnecting(true)

        try {
            await fuel.connect();
        } finally {
            setIsConnecting(false)
        }
    }

    useEffect(() => {
        async function handleConnection() {
            try {
                const isConnected = await fuel.isConnected();
                const authAccounts = await fuel.accounts();
                const account = await fuel.currentAccount();

                if (authAccounts.includes(account)) {
                    setAccount(account);
                    setIsConnected(isConnected);
                }
            } catch {}
        }

        handleConnection();

        fuel?.on(fuel.events.connection, handleConnection);
    }, []);

    return {
        account,
        isConnected,
        isConnecting,
        connect: handleConnect,
    }
}

export {useIsConnected}
