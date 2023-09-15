import {Example} from "../example";
import {useIsConnected} from "../../hooks/fuel";

const IsConnected = () => {
    const {connect, isConnecting, isConnected} = useIsConnected();

    return (
        <Example.Box style={{
            width: '100%',
            display: 'flex',
            justifyContent: 'flex-end',
            alignItems: 'center',
        }}>
            {
                isConnected ?
                'Connected in fuel' :
                    isConnecting ?
                        'Connecting...' :
                        'Not connected in fuel'
            }

            {!isConnected && (
                <Example.Button
                    disabled={isConnecting}
                    onClick={connect}
                    style={{ fontSize: 12, marginLeft: 5 }}
                >
                    Connect
                </Example.Button>
            )}
        </Example.Box>
    )
}

export {IsConnected};
