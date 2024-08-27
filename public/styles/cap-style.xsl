<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" doctype-system="about:legacy-compat"/>
    <xsl:template match="*[local-name()='alert']">
        <html lang="en" dir="ltr">
            <head>
                <title>
                    <xsl:value-of select="*[local-name()='info'][1]/*[local-name()='headline']" />
                </title>
                <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <meta name="description" content="Emergency alert in Common Alerting Protocol (CAP) format"/>
                <meta name="keywords" content="alert, warning, emergency"/>
                <meta name="revisit" content="1 days"/>
                <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min"/>
                <script src="https://unpkg.com/maplibre-gl/dist/maplibre-gl.js" type="text/javascript"></script>
                <link href="https://unpkg.com/maplibre-gl/dist/maplibre-gl.css" rel="stylesheet" />
                <script src="https://unpkg.com/@turf/turf/turf.min.js" type="text/javascript"></script>
                <style>
                html, body {
                    height: 100%;
                    margin: 20px;
                }

                .alert-meta {
                    display: flex;
                    margin: 20px 0;
                    flex-wrap: wrap;
                }

                .alert-meta .alert-meta-item {
                    margin-right: 20px;
                }

                .alert-meta .alert-meta-item b {
                    margin-right: 8px;
                }

                .reference-alerts {
                    margin-bottom: 20px;
                }

                .ref-title {
                    font-weight: bold;
                }

                .cap-map-wrapper {
                    box-shadow: rgba(0, 0, 0, 0.1) 0 1px 3px 0, rgba(0, 0, 0, 0.06) 0 1px 2px 0;
                }

                .map {
                    height: 500px;
                    width: 100%;
                    position: relative;
                }

                .map-legend {
                    display: flex;
                    padding: 4px 8px;
                    align-items: center;
                    background-color: #fff;
                    font-size: 14px;
                    flex-wrap: wrap;
                    width: 100%;
                    border-top: 1px solid #f0f0f0;
                }

                .legend-items {
                    display: flex;
                    align-items: center;
                    flex-wrap: wrap;
                }

                .legend-item {
                    display: flex;
                    align-items: center;
                    margin-left: 10px;
                }

                .map-legend .legend-items .legend-item .legend-color {
                    margin-right: 4px;
                    height: 12px;
                    width: 12px;
                }

                .alert-icon-wrapper {
                    position: relative;
                    width: 32px;
                    height: 32px;
                    border: 1px solid;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    margin-right: 10px;
                }

                .alert-icon-wrapper svg {
                    height: 80%;
                    width: 80%;
                    fill: currentColor;
                }

                .info-item {
                    padding-top: 10px;
                }

                .info-header {
                    font-weight: 600;
                    font-size: 18px;
                    padding: 10px 0;
                }

                .cap-info-summary-item {
                    display: flex;
                    align-items: center;
                    padding-bottom: 10px;
                }

                .cap-info-summary-icon {
                    height: 20px;
                    width: 20px;
                    margin-right: 4px;
                }

                .cap-info-summary-icon svg {
                    height: 100%;
                    width: 100%;
                }

                .cap-info-summary-type {
                    margin-left: 4px;
                    font-weight: 600;
                }

                .cap-info-summary-value {
                    margin-left: 4px;
                }

                .cap-time-wrapper {
                    margin-bottom: 10px;
                    border-radius: 4px;
                }

                .cap-time-wrapper .time-type {
                    font-weight: 600;
                    color: #555;
                }

                .warning-timeline {
                    position: relative;
                    z-index: 0;
                    list-style: none;
                }

                .warning-timeline .warning-timeline__item {
                    position: relative;
                    padding-left: 20px;
                    padding-bottom: 10px;
                }

                .warning-timeline__item:not(:last-child):before {
                    background-image: -webkit-gradient(linear, left bottom, left top, color-stop(60%, #56616c), color-stop(25%, transparent));
                    background-image: -webkit-linear-gradient(bottom, #56616c 60%, transparent 25%);
                    background-image: linear-gradient(0deg, #56616c 60%, transparent 25%);
                    background-size: 1px 5px;
                    content: "";
                    display: block;
                    position: absolute;
                    width: 1px;
                    left: 5px;
                    top: 17px;
                    bottom: -6.5px;
                }

                .warning-timeline__circle {
                    border-radius: 50%;
                    -webkit-box-shadow: rgb(86, 97, 108) 0px 0px 0px 1px inset;
                    box-shadow: rgb(86, 97, 108) 0px 0px 0px 1px inset;
                    height: 11px;
                    left: 0;
                    position: absolute;
                    width: 11px;
                    top: 6.5px;
                }

                .warning-timeline__circle:after {
                    background-color: #56616c;
                    border-radius: 50%;
                    content: "";
                    display: block;
                    height: 7px;
                    width: 7px;
                    left: 2px;
                    position: absolute;
                    top: 2px;
                }
            </style>
            </head>
            <body class="container">
                <!-- To customize the Web page, insert here the HTML code for a page header  -->
                <!-- CAP Headline -->
                <h2 class="title" style="margin: 20px 0">
                    <a style="text-decoration: underline">
                        <xsl:attribute name="href">
                            <xsl:value-of select="*[local-name()='info'][1]/*[local-name()='web']"/>
                        </xsl:attribute>
                        <xsl:value-of select="*[local-name()='info'][1]/*[local-name()='headline']"/>
                    </a>
                </h2>
                <div class="alert-meta">
                    <div class="alert-meta-item">
                        <b>
                    Identifier:
                </b>
                        <span>
                            <xsl:value-of select="*[local-name()='identifier']"/>
                        </span>
                    </div>
                    <div class="alert-meta-item">
                        <b>
                    Sender:
                </b>
                        <span>
                            <xsl:value-of select="*[local-name()='sender']"/>
                        </span>
                    </div>
                    <div class="alert-meta-item">
                        <b>Sent:</b>
                        <span>
                            <xsl:value-of select="*[local-name()='sent']"/>
                        </span>
                    </div>
                    <div class="alert-meta-item">
                        <b>Status:</b>
                        <span>
                            <xsl:value-of select="*[local-name()='status']"/>
                        </span>
                    </div>
                    <div class="alert-meta-item">
                        <b>Message Type:</b>
                        <span>
                            <xsl:value-of select="*[local-name()='msgType']"/>
                        </span>
                    </div>
                    <div class="alert-meta-item">
                        <b>Scope:</b>
                        <span>
                            <xsl:value-of select="*[local-name()='scope']"/>
                        </span>
                    </div>
                </div>
                <xsl:if test="*[local-name()='references']">
                    <div class="reference-alerts">
                        <div class="ref-title">
                    Reference Alerts:
                </div>
                        <ul>
                            <xsl:for-each select="*[local-name()='references']">
                                <li>
                                    <xsl:value-of select="."/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:if>
                <div class="columns is-multiline" style="padding-bottom: 100px">
                    <div class="column is-two-fifths-widescreen is-full-touch">
                        <div class="cap-map-wrapper">
                            <div id="map" class="map">
                                <script type="text/javascript">
                            // default base style
                            const defaultStyle = {
                                'version': 8,
                                'sources': {
                                    'carto-dark': {
                                        'type': 'raster',
                                        'tiles': [
                                            "https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
                                            "https://b.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
                                            "https://c.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png",
                                            "https://d.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png"
                                        ]
                                    },
                                    'carto-light': {
                                        'type': 'raster',
                                        'tiles': [
                                            "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                                            "https://b.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                                            "https://c.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png",
                                            "https://d.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png"
                                        ]
                                    },
                                    'wikimedia': {
                                        'type': 'raster',
                                        'tiles': [
                                            "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png"
                                        ]
                                    }
                                },
                                'layers': [{
                                    'id': 'carto-light-layer',
                                    'source': 'carto-light',
                                    'type': 'raster',
                                    'minzoom': 0,
                                    'maxzoom': 22
                                }]
                            }

                            const capData = {
                                'type': 'FeatureCollection',
                                'features': []
                            };

                            let layerAddedToMap = false;

                            // initialize map
                            const map = new maplibregl.Map({
                                container: "map",
                                style: defaultStyle,
                                center: [0, 0],
                                zoom: 1,
                            });

                            // add zoom control
                            map.addControl(
                                new maplibregl.NavigationControl({
                                    showCompass: false,
                                })
                            );

                            map.on("load", () => {
                                // add cap source
                                map.addSource('cap', {
                                    'type': 'geojson',
                                    'data': capData
                                });

                                // add cap layer
                                map.addLayer({
                                    'id': 'cap-layer',
                                    'type': 'fill',
                                    'source': 'cap',
                                    'paint': {
                                        'fill-color': [
                                            'match',
                                            ['get', 'severity'],
                                            'Extreme', '#d72f2a',
                                            'Severe', '#f89904',
                                            'Moderate', '#e4e616',
                                            'Minor', '#53ffff',
                                            '#3366ff'
                                        ],
                                        'fill-opacity': 0.7,
                                        'fill-outline-color': '#000000'
                                    }
                                });

                                layerAddedToMap = true;
                            });

                            // create cap layer
                            const addAreaPolygon = (capPolygonString, severity, featureId) => {
                                const parts = capPolygonString.split(" ");
                                const coordinates = parts.map((part) => {
                                    const [lat, lng] = part.split(",");
                                    return [parseFloat(lng), parseFloat(lat)];
                                });

                                const feature = {
                                    'type': 'Feature',
                                    'properties': {
                                        'id': featureId,
                                        'severity': severity
                                    },
                                    'geometry': {
                                        'type': 'Polygon',
                                        'coordinates': [coordinates]
                                    }
                                };

                                capData.features.push(feature);
                            }

                            const addAreaCircle = (capCircleString, severity, featureId) => {
                                const parts = capCircleString.split(" ");
                                const [lat, lng] = parts[0].split(",");
                                const center = [parseFloat(lng), parseFloat(lat)];
                                const radius = parseFloat(parts[1]);

                                const options = {
                                    units: 'kilometers',
                                    properties: {"severity": severity, "id": featureId}
                                };
                                const circle = turf.circle(center, radius, options);
                                capData.features.push(circle);
                            };

                            let timerId
                            const loadLayer = () => {
                                if (layerAddedToMap) {
                                    console.log("Map Loaded...")
                                    console.log("Adding CAP data to map...")
                                    map.getSource('cap').setData(capData);

                                    const bounds = turf.bbox(capData);
                                    map.fitBounds(bounds, {
                                        padding: 100
                                    });

                                    if (timerId) {
                                        clearTimeout(timerId);
                                    }
                                } else {
                                    console.log("Waiting for map to load....")
                                    timerId = setTimeout(loadLayer, 1000);
                                }
                            }
                        </script>
                            </div>
                            <div class="map-legend">
                                <div>
                            Alert Severity:
                        </div>
                                <div class="legend-items">
                                    <div class="legend-item">
                                        <div class="legend-color"
                                     style="background-color: rgb(215, 47, 42);"></div>
                                        <div class="legend-label">
                                    Extreme
                                </div>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-color"
                                     style="background-color: rgb(254, 153, 0);"></div>
                                        <div class="legend-label">
                                    Severe
                                </div>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-color"
                                     style="background-color: rgb(255, 255, 0);"></div>
                                        <div class="legend-label">
                                    Moderate
                                </div>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-color"
                                     style="background-color: rgb(3, 255, 255);"></div>
                                        <div class="legend-label">
                                    Minor
                                </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="column is-three-fifths-widescreen is-full-touch featured-item-detail">
                        <div class="tabs is-boxed ">
                            <ul>
                                <xsl:for-each select="*[local-name()='info']">
                                    <li>
                                        <xsl:if test="position()=1">
                                            <xsl:attribute name="class">is-active</xsl:attribute>
                                        </xsl:if>
                                        <xsl:attribute name="data-target">
                                            <xsl:value-of select="concat('info-',position())"/>
                                        </xsl:attribute>
                                        <a>
                                            <span class="alert-icon-wrapper">
                                                <svg id="icon-cap-warning" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 47.996 41.01">
                                                    <path d="M47.668 37.41L27.118 1.8a3.604 3.604 0 0 0-6.24 0L.328 37.41a2.398 2.398 0 0 0 2.08 3.6h43.18a2.398 2.398 0 0 0 2.08-3.6zm-23.67-3.4a2 2 0 1 1 2-2 2.006 2.006 0 0 1-2 2zm2-9a2 2 0 0 1-4 0v-11a2 2 0 1 1 4 0z"
          data-name="Layer 2"/>
                                                </svg>
                                            </span>
                                            <span>
                                                <xsl:value-of select="*[local-name()='event'][1]"/>
                                            </span>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                        <div id="tab-content">
                            <xsl:for-each select="*[local-name()='info']">
                                <xsl:variable name="infoPosition" select="concat('info-', position())"/>
                                <div>
                                    <xsl:if test="not(position()=1)">
                                        <xsl:attribute name="class">is-hidden</xsl:attribute>
                                    </xsl:if>
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="concat('info-',position())"/>
                                    </xsl:attribute>
                                    <div class="info-item">
                                        <div class="cap-info-summary-item">
                                            <span class="cap-info-summary-icon">
                                                <svg xmlns="http://www.w3.org/2000/svg" id="icon-cap-language" viewBox="0 0 512 512">
                                                    <path d="M352 256c0 22.2-1.2 43.6-3.3 64H163.3c-2.2-20.4-3.3-41.8-3.3-64s1.2-43.6 3.3-64H348.7c2.2 20.4 3.3 41.8 3.3 64zm28.8-64H503.9c5.3 20.5 8.1 41.9 8.1 64s-2.8 43.5-8.1 64H380.8c2.1-20.6 3.2-42 3.2-64s-1.1-43.4-3.2-64zm112.6-32H376.7c-10-63.9-29.8-117.4-55.3-151.6c78.3 20.7 142 77.5 171.9 151.6zm-149.1 0H167.7c6.1-36.4 15.5-68.6 27-94.7c10.5-23.6 22.2-40.7 33.5-51.5C239.4 3.2 248.7 0 256 0s16.6 3.2 27.8 13.8c11.3 10.8 23 27.9 33.5 51.5c11.6 26 20.9 58.2 27 94.7zm-209 0H18.6C48.6 85.9 112.2 29.1 190.6 8.4C165.1 42.6 145.3 96.1 135.3 160zM8.1 192H131.2c-2.1 20.6-3.2 42-3.2 64s1.1 43.4 3.2 64H8.1C2.8 299.5 0 278.1 0 256s2.8-43.5 8.1-64zM194.7 446.6c-11.6-26-20.9-58.2-27-94.6H344.3c-6.1 36.4-15.5 68.6-27 94.6c-10.5 23.6-22.2 40.7-33.5 51.5C272.6 508.8 263.3 512 256 512s-16.6-3.2-27.8-13.8c-11.3-10.8-23-27.9-33.5-51.5zM135.3 352c10 63.9 29.8 117.4 55.3 151.6C112.2 482.9 48.6 426.1 18.6 352H135.3zm358.1 0c-30 74.1-93.6 130.9-171.9 151.6c25.5-34.2 45.2-87.7 55.3-151.6H493.4z"></path>
                                                </svg>
                                            </span>
                                            <div class="cap-info-summary-type">
                                        Language:
                                    </div>
                                            <div class="cap-info-summary-value">
                                                <xsl:value-of select="*[local-name()='language'][1]"/>
                                            </div>
                                        </div>
                                        <div class="cap-info-summary-item">
                                            <span class="cap-info-summary-icon">
                                                <svg id="icon-cap-category" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
                                                    <path d="M2.5 1h4.656c.532 0 1.032.219 1.407.594l5.5 5.5a2.018 2.018 0 0 1 0 2.843l-4.157 4.157a2.018 2.018 0 0 1-2.844 0l-5.5-5.5A1.959 1.959 0 0 1 1 7.188V2.5A1.5 1.5 0 0 1 2.5 1Zm2 4.5c.531 0 1-.438 1-1 0-.531-.469-1-1-1-.563 0-1 .469-1 1 0 .563.438 1 1 1Z"></path>
                                                </svg>
                                            </span>
                                            <div class="cap-info-summary-type">
                                        Category:
                                    </div>
                                            <div class="cap-info-summary-value">
                                                <xsl:for-each select="*[local-name()='category']">
                                                    <xsl:value-of select="."/>
                                                </xsl:for-each>
                                            </div>
                                        </div>
                                    </div>
                                    <xsl:if test="*[local-name()='responseType']">
                                        <div class="info-item">
                                            <div class="cap-info-summary-item">
                                                <span class="cap-info-summary-icon">
                                                    <svg id="icon-cap-response" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
                                                        <g>
                                                            <path d="M2.5 26A2.5 2.5 0 0 0 5 23.5 11.577 11.577 0 0 1 16.893 12h22.576l-2.741 2.741a2.5 2.5 0 1 0 3.535 3.535l7.005-7.004a2.5 2.5 0 0 0 0-3.535L40.263.732a2.5 2.5 0 0 0-3.535 3.536L39.459 7H16.893A16.522 16.522 0 0 0 0 23.5 2.5 2.5 0 0 0 2.5 26zM40.263 22.732a2.5 2.5 0 0 0-3.535 3.536L39.459 29H16.893A16.522 16.522 0 0 0 0 45.5a2.5 2.5 0 0 0 5 0A11.577 11.577 0 0 1 16.893 34h22.576l-2.741 2.741a2.5 2.5 0 1 0 3.535 3.535l7.005-7.004a2.5 2.5 0 0 0 0-3.535z"></path>
                                                        </g>
                                                    </svg>
                                                </span>
                                                <div class="cap-info-summary-type">
                                            Response Types:
                                        </div>
                                                <div class="cap-info-summary-value">
                                                    <xsl:for-each select="*[local-name()='responseType']">
                                                        <xsl:if test="position() > 1">,</xsl:if>
                                                        <xsl:value-of select="."/>
                                                    </xsl:for-each>
                                                </div>
                                            </div>
                                        </div>
                                    </xsl:if>
                                    <xsl:variable name="severity" select="*[local-name()='severity'][1]"/>
                                    <div class="info-item">
                                        <div class="cap-info-summary-item">
                                            <span class="cap-info-summary-icon">
                                                <svg id="icon-cap-clock" xmlns="http://www.w3.org/2000/svg"
     viewBox="0 0 16 16">
                                                    <path d="M8 16c-4.438 0-8-3.563-8-8 0-4.406 3.563-8 8-8 4.406 0 8 3.594 8 8 0 4.438-3.594 8-8 8Zm-.75-8c0 .25.125.5.313.625l3 2a.718.718 0 0 0 1.03-.188c.25-.343.157-.812-.187-1.062L8.75 7.625V3.75c0-.406-.344-.75-.781-.75a.76.76 0 0 0-.75.75L7.25 8Z"></path>
                                                </svg>
                                            </span>
                                            <div class="cap-info-summary-type">
                                        Urgency:
                                    </div>
                                            <div class="cap-info-summary-value">
                                                <xsl:value-of select="*[local-name()='urgency'][1]"/>
                                            </div>
                                        </div>
                                        <div class="cap-info-summary-item">
                                            <span class="cap-info-summary-icon">
                                                <svg id="icon-cap-warning" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 47.996 41.01">
                                                    <path d="M47.668 37.41L27.118 1.8a3.604 3.604 0 0 0-6.24 0L.328 37.41a2.398 2.398 0 0 0 2.08 3.6h43.18a2.398 2.398 0 0 0 2.08-3.6zm-23.67-3.4a2 2 0 1 1 2-2 2.006 2.006 0 0 1-2 2zm2-9a2 2 0 0 1-4 0v-11a2 2 0 1 1 4 0z"
          data-name="Layer 2"/>
                                                </svg>
                                            </span>
                                            <div class="cap-info-summary-type">
                                        Severity:
                                    </div>
                                            <div class="cap-info-summary-value">
                                                <xsl:value-of select="$severity"/>
                                            </div>
                                        </div>
                                        <div class="cap-info-summary-item">
                                            <span class="cap-info-summary-icon">
                                                <svg id="icon-cap-certainty" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
                                                    <path d="M7 8c0-.531.438-1 1-1 .531 0 1 .469 1 1 0 .563-.469 1-1 1-.563 0-1-.438-1-1Zm1-8c.531 0 1 .469 1 1v.344A6.764 6.764 0 0 1 14.656 7H15c.531 0 1 .469 1 1 0 .563-.469 1-1 1h-.344c-.437 2.938-2.75 5.25-5.656 5.688V15c0 .563-.469 1-1 1-.563 0-1-.438-1-1v-.313A6.762 6.762 0 0 1 1.312 9H1c-.563 0-1-.438-1-1 0-.531.438-1 1-1h.313C1.75 4.094 4.063 1.781 7 1.344V1c0-.531.438-1 1-1ZM7 12.656V12c0-.531.438-1 1-1 .531 0 1 .469 1 1v.656A4.685 4.685 0 0 0 12.625 9H12c-.563 0-1-.438-1-1 0-.531.438-1 1-1h.625A4.69 4.69 0 0 0 9 3.375V4c0 .563-.469 1-1 1-.563 0-1-.438-1-1v-.625A4.685 4.685 0 0 0 3.344 7H4c.531 0 1 .469 1 1 0 .563-.469 1-1 1h-.656A4.68 4.68 0 0 0 7 12.656Z"></path>
                                                </svg>
                                            </span>
                                            <div class="cap-info-summary-type">
                                        Certainty:
                                    </div>
                                            <div class="cap-info-summary-value">
                                                <xsl:value-of select="*[local-name()='certainty'][1]"/>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-header">
                                    Time
                                </div>
                                        <div class="info-detail">
                                            <div class="cap-time-wrapper">
                                                <ul class="warning-timeline">
                                                    <xsl:if test="*[local-name()='effective'][1]">
                                                        <li class="warning-timeline__item">
                                                            <div class="warning-timeline__circle"></div>
                                                            <div>
                                                                <span class="time-type">
                                                            Effective:
                                                        </span>
                                                                <span>
                                                                    <xsl:value-of select="*[local-name()='effective'][1]"/>
                                                                </span>
                                                            </div>
                                                        </li>
                                                    </xsl:if>
                                                    <xsl:if test="*[local-name()='onset'][1]">
                                                        <li class="warning-timeline__item">
                                                            <div class="warning-timeline__circle"></div>
                                                            <div>
                                                                <span class="time-type">
                                                            Onset:
                                                        </span>
                                                                <span>
                                                                    <xsl:value-of select="*[local-name()='onset'][1]"/>
                                                                </span>
                                                            </div>
                                                        </li>
                                                    </xsl:if>
                                                    <li class="warning-timeline__item">
                                                        <div class="warning-timeline__circle"></div>
                                                        <div>
                                                            <span class="time-type">
                                                        Expires:
                                                    </span>
                                                            <xsl:value-of select="*[local-name()='expires'][1]"/>
                                                        </div>
                                                    </li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-header">
                                    Headline
                                </div>
                                        <div class="info-detail">
                                            <xsl:value-of select="*[local-name()='headline'][1]"/>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-header">
                                    Description
                                </div>
                                        <div class="info-detail">
                                            <xsl:value-of select="*[local-name()='description'][1]"/>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-header">
                                    Instruction
                                </div>
                                        <div class="info-detail">
                                            <xsl:value-of select="*[local-name()='instruction'][1]"/>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-header">
                                    Area
                                </div>
                                        <div class="info-detail">
                                            <xsl:for-each select="*[local-name()='area']">
                                                <xsl:variable name="areaPosition"
                                                      select="concat($infoPosition,'-area-', position())"/>
                                                <div style="margin-bottom: 8px">
                                                    <xsl:value-of select="*[local-name()='areaDesc'][1]"/>
                                                </div>
                                                <xsl:for-each select="*[local-name()='polygon']">
                                                    <xsl:variable name="polyPosition"
                                                          select="concat($areaPosition,'-poly-', position())"/>
                                                    <script>
                                                addAreaPolygon('
                                                        <xsl:value-of select="."/>', '
                                                        <xsl:value-of select="$severity"/>', '
                                                        <xsl:value-of select="$polyPosition"/>');
                                                    </script>
                                                </xsl:for-each>
                                                <xsl:for-each select="*[local-name()='circle']">
                                                    <xsl:variable name="circlePosition"
                                                          select="concat($areaPosition,'-circle-', position())"/>
                                                    <script>
                                                addAreaCircle('
                                                        <xsl:value-of select="."/>', '
                                                        <xsl:value-of select="$severity"/>', '
                                                        <xsl:value-of select="$circlePosition"/>');
                                                    </script>
                                                </xsl:for-each>
                                            </xsl:for-each>
                                        </div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-header">
                                    Contact
                                </div>
                                        <div class="info-detail">
                                            <xsl:value-of select="*[local-name()='contact'][1]"/>
                                        </div>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <script>
                        loadLayer();
                    </script>
                        </div>
                    </div>
                </div>
                <!-- CAP Elements -->
                <!-- To customize the Web page, insert here the HTML code for a page footer  -->
                <script>
            document.addEventListener('DOMContentLoaded', () => {
                // Tabs
                const tabs = document.querySelectorAll('.tabs li')
                const tabContentBoxes = document.querySelectorAll('#tab-content > div')

                tabs.forEach((tab) => {
                    tab.addEventListener('click', () => {
                        tabs.forEach(item => item.classList.remove('is-active'))

                        tab.classList.add('is-active')

                        const target = tab.dataset.target;

                        tabContentBoxes.forEach(box => {
                            if (box.getAttribute('id') === target) {
                                box.classList.remove('is-hidden')
                            } else {
                                box.classList.add('is-hidden')
                            }
                        })
                    })
                })
            });
        </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
