# Gebruik de Node 18 Alpine image
FROM node:18-alpine

# Installeer systeem tools (nodig voor bash scripts en build tools)
RUN apk add --no-cache python3 bash make g++

# Zet de working directory
WORKDIR /app

# Kopieer package files eerst voor betere caching
COPY package*.json ./

# Installeer ALLE dependencies (nodig omdat tsc in dependencies staat)
RUN npm install

# Kopieer de rest van de applicatie
COPY . .

# Bouw het project met het script uit je package.json
RUN npm run build

# Zorg dat de CLI en de adapter uitvoerbaar zijn
RUN chmod +x bin/cli.js 2>/dev/null || :
RUN chmod +x dist/*.js 2>/dev/null || :

# Create workspace directory (standaard voor MCP servers)
RUN mkdir -p /tmp/mcp-workspace && chmod 777 /tmp/mcp-workspace
ENV DEFAULT_WORKSPACE=/tmp/mcp-workspace

# BELANGRIJK: Smithery verwacht dat de server start.
# Volgens jouw package.json is de start-file voor Smithery: dist/smithery-adapter.js
# Als dit bestand NIET bestaat na de build, verander dit dan naar dist/main.js
CMD ["node", "dist/smithery-adapter.js"]
