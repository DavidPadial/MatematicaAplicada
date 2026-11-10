function FindProxyForURL(url, host) {

    host = host.toLowerCase();

    // Recursos UMA: acceso directo
    if (
        isPlainHostName(host) ||
        shExpMatch(host, "*.uma.es") ||
        host == "uma.es" ||
        isInNet(dnsResolve(host), "150.214.0.0", "255.255.0.0")
    ) {
        return "DIRECT";
    }

    // Software docente autorizado vía SATD
    if (
        shExpMatch(host, "*.r-project.org")   ||
        host == "r-project.org"              ||

        shExpMatch(host, "*.scilab.org")     ||
        host == "scilab.org"                 ||

        shExpMatch(host, "*.mathworks.com")  ||
        host == "mathworks.com"              ||

        shExpMatch(host, "*.sentinelone.net") ||
        host == "sentinelone.net"             ||

        shExpMatch(host, "*.jsdelivr.net")   ||
        host == "jsdelivr.net"               ||

        shExpMatch(host, "*.jsdelivr.com")   ||
        host == "jsdelivr.com"
    ) {
        return "PROXY proxy.satd.uma.es:3128";
    }

    // Todo lo demás por el proxy de examen
    return "PROXY proxy.matapexamen.uma.es:3128";
}
