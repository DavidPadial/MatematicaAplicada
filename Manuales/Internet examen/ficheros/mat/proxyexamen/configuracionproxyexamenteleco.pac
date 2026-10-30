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

    // 2. Proxy SATD para dominios específicos
    if (
        shExpMatch(host, "*.r-project.org")   || host === "r-project.org"   ||
        shExpMatch(host, "*.scilab.org")      || host === "scilab.org"      ||
        shExpMatch(host, "*.mathworks.com")   || host === "mathworks.com"   ||
        shExpMatch(host, "*.sentinelone.net") || host === "sentinelone.net" ||
        shExpMatch(host, "*.jsdelivr.net")    || host === "jsdelivr.net"    ||
        shExpMatch(host, "*.jsdelivr.com")    || host === "jsdelivr.com"
    ) {
        return "PROXY proxy.satd.uma.es:3128";
    }

    // 3. Proxy por defecto (Matapexamen)
    return "PROXY proxy.matapexamen.uma.es:3128";
}
