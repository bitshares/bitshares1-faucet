var timeout = 5000;

$(function () {

  if ($('#referral_codes').length) {
    setTimeout(updateReferralCodesStatus, timeout);
  } else if ($('#referral_code').length) {
    setTimeout(updateReferralCodeStatus, timeout);
  }
});

function updateReferralCodesStatus() {
  sendRequest($('#referral_codes').data('url'))
  setTimeout(updateReferralCodesStatus, timeout);
}

function updateReferralCodeStatus() {
  sendRequest($('#referral_code').data('url'))
  setTimeout(updateReferralCodesStatus, timeout);
}

function sendRequest(url) {
  $.ajax({
    dataType: 'script',
    url: url
  });
}

