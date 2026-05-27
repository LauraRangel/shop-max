// Sistema POS - Carrito de ventas

let carrito = [];

function agregarFila() {
    const select = document.getElementById("selProducto");
    const idProducto = select.value;
    const nombreProducto = select.options[select.selectedIndex].text;
    const precio = parseFloat(select.options[select.selectedIndex].dataset.precio);

    if (!idProducto) {
        alert("Selecciona un producto");
        return;
    }

    let existe = false;
    for (let item of carrito) {
        if (item.id === idProducto) {
            item.cantidad++;
            existe = true;
            break;
        }
    }

    if (!existe) {
        carrito.push({
            id: idProducto,
            nombre: nombreProducto,
            precio: precio,
            cantidad: 1
        });
    }

    renderCarrito();
    select.value = "";
}

function renderCarrito() {
    const tbody = document.querySelector("#tablaCarrito tbody");
    tbody.innerHTML = "";
    let total = 0;

    carrito.forEach((item, idx) => {
        const subtotal = item.precio * item.cantidad;
        total += subtotal;
        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td>${item.nombre}</td>
            <td>S/. ${item.precio.toFixed(2)}</td>
            <td><input type="number" min="1" value="${item.cantidad}" onchange="cambiarCantidad(${idx}, this.value)"></td>
            <td>S/. ${subtotal.toFixed(2)}</td>
            <td><button type="button" class="btn btn-sm btn-danger" onclick="eliminarFila(${idx})">X</button></td>
        `;
        tbody.appendChild(tr);
    });

    document.getElementById("totalVenta").textContent = total.toFixed(2);
}

function cambiarCantidad(idx, cantidad) {
    carrito[idx].cantidad = parseInt(cantidad);
    renderCarrito();
}

function eliminarFila(idx) {
    carrito.splice(idx, 1);
    renderCarrito();
}

function guardarVenta() {
    if (carrito.length === 0) {
        alert("El carrito está vacío");
        return;
    }

    const idCliente = document.getElementById("selCliente").value;
    const tipoPago  = document.getElementById("selTipoPago").value;
    const total     = document.getElementById("totalVenta").textContent;

    const form = document.createElement("form");
    form.method = "POST";
    form.action = "ServletGuardarVenta";

    function addField(name, value) {
        const input = document.createElement("input");
        input.type  = "hidden";
        input.name  = name;
        input.value = value;
        form.appendChild(input);
    }

    addField("idCliente", idCliente);
    addField("tipoPago",  tipoPago);
    addField("total",     total);
    addField("numItems",  carrito.length);

    carrito.forEach((item, i) => {
        addField("item_id_"     + i, item.id);
        addField("item_cant_"   + i, item.cantidad);
        addField("item_precio_" + i, item.precio.toFixed(2));
    });

    document.body.appendChild(form);
    form.submit();
}

function cerrarModal() {
    const modal = document.getElementById("modalPOS");
    modal.style.display = "none";
}
