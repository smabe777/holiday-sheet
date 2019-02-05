let changes = {};
let url = "";

function radio_clicked(id, date, type) {
  radio = document.getElementById(type + "_" + id);
  changes[date] = type;
}
var handleFormSubmit = function handleFormSubmit(event) {
  // Stop the form from submitting since weâ€™re handling that with AJAX.
  event.preventDefault();
};

var dateControl = document.querySelector('input[type="date"]');
dateControl.value = new Date();