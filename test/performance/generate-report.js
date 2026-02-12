/**
 * Simple Report Generator
 * Legge performance-data.csv e genera un report HTML standalone con grafici.
 * Sovrascrive il file precedente ad ogni esecuzione.
 */

const fs = require('fs');
const path = require('path');

const CSV_PATH = path.join(__dirname, 'results', 'performance-data.csv');
const HTML_PATH = path.join(__dirname, 'results', 'report.html');

function generateReport() {
    if (!fs.existsSync(CSV_PATH)) {
        console.error('❌ File CSV non trovato:', CSV_PATH);
        return;
    }

    const csvContent = fs.readFileSync(CSV_PATH, 'utf-8');
    const lines = csvContent.trim().split('\n');
    const headers = lines[0].split(',');
    
    const data = [];
    
    // Parsing CSV (salta header)
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (!line) continue;
        
        const values = line.split(',');
        if (values.length !== headers.length) continue;
        if (values[0] === 'undefined') continue; // Salta righe errate
        
        const entry = {};
        headers.forEach((header, index) => {
            entry[header.trim()] = values[index].trim();
        });
        
        // Rimuovi duplicati/esecuzioni precedenti, mantieni l'ultimo dato
        const existingIndex = data.findIndex(d => d.Contract === entry.Contract);
        if (existingIndex >= 0) {
            data[existingIndex] = entry;
        } else {
            data.push(entry);
        }
    }

    // Ordina per complessità (Simple -> Medium -> Complex)
    const order = ['BN_Simple', 'BN_Medium', 'BN_Complex'];
    data.sort((a, b) => order.indexOf(a.Contract) - order.indexOf(b.Contract));

    // Formatter data per footer in italiano
    const now = new Date().toLocaleString('it-IT', { 
        year: 'numeric', month: 'long', day: 'numeric', 
        hour: '2-digit', minute: '2-digit' 
    });

    const htmlContent = `
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analisi Prestazioni Contratti</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --bg-primary: #0f0f23;
            --bg-secondary: #1a1a2e;
            --bg-card: #232342; 
            --text-primary: #ffffff;
            --text-secondary: #b8b8d1;
            --border-color: rgba(255, 255, 255, 0.1);
            --accent-primary: #667eea;
            --accent-secondary: #764ba2;
            --success: #00f2fe;
            --warning: #fee140;
            --danger: #f5576c;
        }

        body { 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
            margin: 0; 
            padding: 40px; 
            background-color: var(--bg-primary); 
            color: var(--text-primary); 
        }

        .container { 
            max-width: 1100px; 
            margin: 0 auto; 
            background-color: var(--bg-secondary); 
            padding: 40px; 
            border-radius: 16px; 
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5); 
            border: 1px solid var(--border-color);
        }

        h1 { 
            color: var(--text-primary); 
            text-align: center; 
            margin-bottom: 40px; 
            font-weight: 700; 
            letter-spacing: -0.5px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 40px; }
        
        .stat-card { 
            background: var(--bg-card); 
            padding: 24px; 
            border-radius: 12px; 
            text-align: center; 
            border: 1px solid var(--border-color); 
            transition: transform 0.2s; 
        }
        
        .stat-card:hover { transform: translateY(-4px); border-color: var(--accent-primary); }
        
        .stat-card h3 { 
            margin: 0 0 12px 0; 
            color: var(--text-secondary); 
            font-size: 0.85em; 
            text-transform: uppercase; 
            letter-spacing: 1px; 
        }
        
        .stat-card .value { font-size: 2em; font-weight: 700; color: var(--text-primary); margin-bottom: 4px; }
        .stat-card .unit { font-size: 0.9em; color: var(--text-secondary); }

        .charts-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-bottom: 50px; }
        
        canvas { width: 100% !important; height: 350px !important; }

        h2 { 
            font-size: 1.4em; 
            margin-bottom: 24px; 
            color: var(--text-primary); 
            border-bottom: 1px solid var(--border-color); 
            padding-bottom: 12px; 
        }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 0.95em; }
        
        th, td { 
            padding: 16px; 
            text-align: left; 
            border-bottom: 1px solid var(--border-color); 
            color: var(--text-secondary);
        }
        
        th { 
            font-weight: 600; 
            color: var(--accent-primary); 
            text-transform: uppercase; 
            font-size: 0.8em; 
            letter-spacing: 0.5px;
        }
        
        td { color: var(--text-primary); }
        
        tr:last-child td { border-bottom: none; }
        tr:hover td { background-color: rgba(255,255,255,0.02); }

        .footer { 
            text-align: center; 
            margin-top: 60px; 
            color: var(--text-secondary); 
            font-size: 0.85em; 
            border-top: 1px solid var(--border-color); 
            padding-top: 24px; 
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Analisi Prestazioni Smart Contract</h1>
        
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Miglior Efficienza</h3>
                <div class="value" style="color: #4facfe">${data[0].Contract}</div>
                <div class="unit">${parseInt(data[0].CalcGas).toLocaleString('it-IT')} gas</div>
            </div>
            <div class="stat-card">
                <h3>Massima Complessità</h3>
                <div class="value" style="color: #fa709a">${data[data.length-1].Contract}</div>
                <div class="unit">${parseInt(data[data.length-1].CalcGas).toLocaleString('it-IT')} gas</div>
            </div>
            <div class="stat-card">
                <h3>Trend di Crescita</h3>
                <div class="value" style="color: #fee140">Lineare</div>
                <div class="unit">~20k gas / step</div>
            </div>
        </div>

        <div class="charts-container">
            <div>
                <canvas id="gasChart"></canvas>
            </div>
            <div>
                <canvas id="timeChart"></canvas>
            </div>
        </div>

        <h2>📋 Metriche Dettagliate</h2>
        <table>
            <thead>
                <tr>
                    <th>Contratto</th>
                    <th>Config</th>
                    <th>Dim. Bytecode</th>
                    <th>Gas Deploy</th>
                    <th>Gas Config</th>
                    <th>Gas Calcolo</th>
                </tr>
            </thead>
            <tbody>
                ${data.map(row => `
                <tr>
                    <td><strong>${row.Contract}</strong></td>
                    <td>${row.Facts}F, ${row.Evidences}E</td>
                    <td>${parseInt(row['Size(bytes)']).toLocaleString('it-IT')}</td>
                    <td>${parseInt(row.DeployGas).toLocaleString('it-IT')}</td>
                    <td>${parseInt(row.ConfigGas).toLocaleString('it-IT')}</td>
                    <td><strong style="color: #4facfe">${parseInt(row.CalcGas).toLocaleString('it-IT')}</strong></td>
                </tr>
                `).join('')}
            </tbody>
        </table>

        <div class="footer">
            Report generato il ${now} • Performance Suite v1.1 • Dark Mode Active
        </div>
    </div>

    <script>
        const data = ${JSON.stringify(data)};
        const labels = data.map(d => d.Contract);

        Chart.defaults.color = '#b8b8d1';
        Chart.defaults.borderColor = 'rgba(255, 255, 255, 0.1)';

        // Gas Chart
        new Chart(document.getElementById('gasChart'), {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Gas Calcolo (Inferenza)',
                        data: data.map(d => d.CalcGas),
                        backgroundColor: '#667eea',
                        borderRadius: 4,
                        barThickness: 30
                    },
                    {
                        label: 'Gas Configurazione',
                        data: data.map(d => d.ConfigGas),
                        backgroundColor: '#232342',
                        borderColor: '#667eea',
                        borderWidth: 1,
                        borderRadius: 4,
                        barThickness: 30
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Consumo Gas (Minore è meglio)', font: { size: 14, weight: 'bold' }, color: '#ffffff' },
                    legend: { position: 'bottom', labels: { boxWidth: 12 } }
                },
                scales: {
                    y: { beginAtZero: true, stacked: true, grid: { color: 'rgba(255,255,255,0.05)' } },
                    x: { stacked: true, grid: { display: false } }
                }
            }
        });

        // Time Chart
        new Chart(document.getElementById('timeChart'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Tempo di Deploy (ms)',
                    data: data.map(d => d['DeployTime(ms)']),
                    borderColor: '#00f2fe',
                    backgroundColor: 'rgba(0, 242, 254, 0.1)',
                    borderWidth: 2,
                    pointBackgroundColor: '#0f0f23',
                    pointBorderColor: '#00f2fe',
                    pointRadius: 6,
                    pointHoverRadius: 8,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Latenza Deploy (ms)', font: { size: 14, weight: 'bold' }, color: '#ffffff' },
                    legend: { position: 'bottom' }
                },
                scales: {
                    y: { beginAtZero: false, grid: { color: 'rgba(255,255,255,0.05)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    </script>
</body>
</html>
    `;

    fs.writeFileSync(HTML_PATH, htmlContent);
    console.log(`✅ Report generato: ${HTML_PATH}`);
}

generateReport();
