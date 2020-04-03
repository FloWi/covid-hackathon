

var mapboxgl = require('mapbox-gl/dist/mapbox-gl.js');

mapboxgl.accessToken = 'pk.eyJ1IjoiamFudHh1IiwiYSI6ImNrODF0NjMzZDBiOTMzaG93YWc2YXV2NnUifQ.WMxyoiOInTp6UNS2zJyKrg';

exports.makeMapUncurried = function (container) {
    return function () {
        console.log("Starting to create map");
        var map = new mapboxgl.Map({
            container: container, // container id
            style: 'mapbox://styles/mapbox/streets-v11',
            center: [6.961424, 50.912915], // starting position
            zoom: 9 // starting zoom
        });

        // Add zoom and rotation controls to the map.
        map.addControl(new mapboxgl.NavigationControl());

        console.log("Created map");
        return map;
    }
}

exports.setCenterUncurried = function (map, lat, lon) {
    return function () {
        map.setCenter([lon, lat]);
    }
}

exports.setZoomUncurried = function (map, zoom) {
    return function () {
        map.setZoom(zoom);
    }
}

exports.addMarkerUncurried = function (map, lat, lon, title, description) {
    return function () {
        var el = document.createElement('i');
        el.nodeValue = 'add';
        el.className = 'material-icons';

        console.log("About to add marker ~> " + el);
        var marker = new mapboxgl.Marker(el)
            .setLngLat([lat, lon])
            .setPopup(new mapboxgl.Popup({ offset: 25 })
                .setHTML('<h3>' + title + '</h3><p>' + description + '</p>'))
            .addTo(map);
        console.log("Added marker" + marker );
    }
}