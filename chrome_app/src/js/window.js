(function(){
  function valueChanged(settings){
    $('#room_id').val(settings.room_id);
    $('#token').val(settings.token);
    console.log('value changed.');
  }

  $(document).on('click', '#save_settings', function(event) {
    var settings = {
      "room_id": $('#room_id').val(),
      "token":   $('#token').val()
    }
    chrome.storage.sync.set({settings: JSON.stringify(settings)}, function() {
      console.log('setting saved.');
    });
    event.preventDefault();
  });

  $(document).on('click', '[data-remote]', function(event) {
    var message = {
      room_id: $('#room_id').val(),
      from:    'ChromeApp',
      message: 'lita remote ' + $(this).data('remote')
    };
    var url = 'https://api.hipchat.com/v1/rooms/message?format=json&auth_token=' + $('#token').val();

    $.ajax({
      type: "POST",
      url: url,
      data: message,
      success: function(res) {
        console.log(res);
      },
      error: function (res) {
        console.log(res);
      }
    });

  });

  chrome.storage.onChanged.addListener(function(changes, namespace) {
    if (changes["settings"]) {
      valueChanged(JSON.parse(changes["settings"].newValue));
      console.log('chrome.storage.onChanged');
    }
  });
  chrome.storage.sync.get("settings", function(data) {
    valueChanged(JSON.parse(data.settings));
    console.log('chrome.storage.sync.get')
  });
  console.log('start')

})();