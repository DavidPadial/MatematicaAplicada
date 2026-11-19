function FindProxyForURL(url, host) {
    host = host.toLowerCase();

    if (
        isPlainHostName(host) ||
        shExpMatch(host, "*.uma.es") ||
        host == "uma.es" ||
        isInNet(dnsResolve(host), "150.214.0.0", "255.255.0.0")
    ) {
        return "DIRECT";
    }

    return "PROXY proxy.satd.uma.es:3128";
}
