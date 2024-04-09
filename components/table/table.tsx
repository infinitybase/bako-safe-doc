

export type ITable = {
    header: string[];
    rows: string[][];
}

const styles = {
    container: {
        margin: '8px',
    },
    table: {
        width: '100%',
    },
    th: {
        border: '1px solid black',
        padding: '8px',
    },
    td: {
        border: '1px solid black',
        padding: '8px'
    },
}

const TableComponent = ({header, rows}: ITable) => {
    return (
        // return (
        <div>
            <table style={styles.table}>
                <thead>
                <tr>
                    {header?.map((item, index) => {
                        return <th key={`header:${index}`} style={styles.th}>{item}</th>
                    })}            
                </tr>
                </thead>
                <tbody>
                    {rows?.map((item, index) => {
                        console.log(item)
                        return <tr key={`row:${index}`}>
                                {item.map((col, index) => {
                                    return <td key={`col:${index}`} style={styles.td}>col</td>
                                })}
                            </tr>
                    })}
                
                </tbody>
            </table>
        </div>  
    )
}

export {TableComponent}


// return (
//     <div style={{ border: '1px solid red' }}>
//         <table style={{ borderCollapse: 'collapse', width: '100%' }}>
//             <thead>
//             <tr>
//                 <th style={styles.th}>Cabeçalho 1</th>
//                 <th style={styles.th}>Cabeçalho 2</th>
//                 <th style={styles.th}>Cabeçalho 3</th>
//             </tr>
//             </thead>
//             <tbody>
//             <tr>
//                 <td style={styles.td}>Coluna 1-1</td>
//                 <td className="centralizado" style={styles.td}>Coluna 2-1</td>
//                 <td style={styles.td}>Coluna 3-1</td>
//             </tr>
//             <tr>
//                 <td style={styles.td}>Coluna 1-2</td>
//                 <td className="centralizado" style={styles.td}>Coluna 2-2</td>
//                 <td style={styles.td}>Coluna 3-2</td>
//             </tr>
//             <tr>
//                 <td style={styles.td}>Coluna 1-3</td>
//                 <td className="centralizado" style={styles.td}>Coluna 2-3</td>
//                 <td style={styles.td}>Coluna 3-3</td>
//             </tr>
//             </tbody>
//         </table>
//     </div>  