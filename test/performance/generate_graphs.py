import pandas as pd
import matplotlib.pyplot as plt
import os
import sys

# Define paths
csv_path = r'c:\Users\andre\Documents\GitHub\ProgettoSoftwareSecurity\test\performance\results\performance-data.csv'
output_dir = r'c:\Users\andre\Documents\GitHub\ProgettoSoftwareSecurity\Software Security Relazione\backmatter\image'

# Check if CSV exists
if not os.path.exists(csv_path):
    print(f"Error: CSV file not found at {csv_path}")
    sys.exit(1)

# Read CSV
df = pd.read_csv(csv_path)

# Set style
plt.style.use('ggplot')

# 1. Gas Usage (Config vs Calc) - Matches report.html focus
plt.figure(figsize=(10, 6))
bar_width = 0.35
index = range(len(df))

# Plot bars
plt.bar(index, df['ConfigGas'], bar_width, label='Gas Configurazione (Setup)', color='#3498db')
plt.bar([i + bar_width for i in index], df['CalcGas'], bar_width, label='Gas Inferenza (Operativo)', color='#2ecc71')

# Labels and Title
plt.xlabel('Complessità del Contratto', fontsize=12)
plt.ylabel('Gas Utilizzato (unità)', fontsize=12)
plt.title('Costi Operativi: Configurazione vs Inferenza', fontsize=14)
plt.xticks([i + bar_width/2 for i in index], df['Contract'])
plt.legend()
plt.tight_layout()

# Save
plt.savefig(os.path.join(output_dir, 'gas_consumption.png'), dpi=300)
print("Saved gas_consumption.png")
plt.close()

# 2. Execution Time (Deploy vs Config vs Calc)
plt.figure(figsize=(10, 6))
bar_width = 0.25
index = range(len(df))

plt.bar(index, df['DeployTime(ms)'], bar_width, label='Tempo Deploy', color='#e74c3c')
plt.bar([i + bar_width for i in index], df['ConfigTime(ms)'], bar_width, label='Tempo Configurazione', color='#3498db')
plt.bar([i + 2 * bar_width for i in index], df['CalcTime(ms)'], bar_width, label='Tempo Inferenza', color='#2ecc71')

plt.xlabel('Complessità del Contratto', fontsize=12)
plt.ylabel('Tempo (ms) - Scala Logaritmica', fontsize=12)
plt.title('Tempi di Esecuzione per Fase (Scala Log)', fontsize=14)
plt.yscale('log') # Log scale to make small inference times visible
plt.xticks([i + bar_width for i in index], df['Contract'])
plt.legend()
plt.tight_layout()

plt.savefig(os.path.join(output_dir, 'execution_time.png'), dpi=300)
print("Saved execution_time.png")
plt.close()

# 3. Contract Size
plt.figure(figsize=(8, 5))
plt.bar(df['Contract'], df['Size(bytes)'], color='#9b59b6', width=0.5)
plt.xlabel('Complessità del Contratto', fontsize=12)
plt.ylabel('Dimensione Bytecode (bytes)', fontsize=12)
plt.title('Dimensione Smart Contract', fontsize=14)
plt.tight_layout()

plt.savefig(os.path.join(output_dir, 'contract_size.png'), dpi=300)
print("Saved contract_size.png")
plt.close()
