function FindProxyForURL(url, host) {
    host = host.toLowerCase();

    // 1. SIN PROXY (Directo)
    if (
        isPlainHostName(host) ||
        shExpMatch(host, "*.uma.es") ||
        host === "uma.es" ||
        shExpMatch(host, "150.214.*") ||
        isInNet(host, "150.214.0.0", "255.255.0.0")
    ) {
        return "DIRECT";
    }

    // 3. Proxy por defecto (SATD)
    return "PROXY proxy.satd.uma.es:3128";
}
