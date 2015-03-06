$(function () {
  setTimeout(updateReferralCodesStatus, 5000);
});

function updateReferralCodesStatus() {
  var $table_wrapper = $('#referral_codes');

  $.ajax({
    dataType: 'json',
    url: $table_wrapper.data('url'),
    complete: function (data) {
      $table_wrapper.html(data.responseText);
    }
  });
  setTimeout(updateReferralCodesStatus, 5000);
}

