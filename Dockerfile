# --- Build Stage ---
FROM node:18-alpine AS builder

WORKDIR /app

# Kopieer package files
COPY package*.json ./

# Installeer dependencies (inclusief devDeps voor tsc)
RUN npm install

# Kopieer de rest van de code
COPY . .

# Bouw het project
RUN npm run build

# --- Runtime Stage ---
FROM node:18-alpine

WORKDIR /app

# Kopieer alleen wat nodig is van de builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Optioneel: Kopieer de bin map als je die hebt voor de CLI
COPY --from=builder /app/bin ./bin 2>/dev/null || :

# Omgevingsvariabelen voor MCP
RUN mkdir -p /tmp/mcp-workspace && chmod 777 /tmp/mcp-workspace
ENV DEFAULT_WORKSPACE=/tmp/mcp-workspace

# Start de server. 
# LET OP: Controleer of dit bestand bestaat na 'npm run build'
# Meestal is het 'dist/index.js' of 'dist/smithery-adapter.js'
CMD ["node", "dist/index.js"]
