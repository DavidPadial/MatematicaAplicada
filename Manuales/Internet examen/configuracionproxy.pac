function FindProxyForURL(url, host) {
    // 1. Páginas específicas que SIEMPRE quieres que vayan por el proxy SATD
    // Reemplaza "ejemplo.com" por las webs que necesitas. 
    // Recuerda cambiar el puerto :3128 si tu universidad usa otro.
    if (shExpMatch(host, "*.wikipedia.org") || shExpMatch(host, "ejemplo.com")) {
        return "PROXY proxy.satd.uma.es:3128"; 
    }

    // 2. Por defecto, para todo lo demás, sigue la configuración del sistema.
    // Al devolver "DIRECT", el navegador usará el proxy que tu script del sistema
    // haya activado en ese momento (SATD o Exámenes) junto con sus excepciones habituales.
    return "DIRECT";
}
