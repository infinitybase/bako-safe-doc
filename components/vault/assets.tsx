import {Example} from "../example";
import {useVault} from "../../hooks";
import {useEffect} from "react";
import {IsConnected} from "../fuel/IsConnected";

const VaultAssets = () => {
    const {create, findAssets, assets, sendBalance} = useVault();

    useEffect(() => {
        create();
    }, []);

    return (
        <Example.Container>
            <Example.Box as="code">
                {assets && JSON.stringify(assets, undefined, 2)}
            </Example.Box>
            <Example.Box style={{ display: 'flex', gap: 10 }}>
                <Example.Button onClick={findAssets}>
                    Get assets
                </Example.Button>
                <Example.Button onClick={sendBalance}>
                    Send asset
                </Example.Button>
            </Example.Box>
            <IsConnected />
        </Example.Container>
    )
}

export {VaultAssets}
