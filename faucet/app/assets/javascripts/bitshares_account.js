$(function () {
  var $subscribe_notification = $('.subscribe_notification');
  var $subscription_link = $('.subscription');

  $($subscribe_notification).on('click', $subscription_link, function (e) {
    $.ajax({
      url: $subscription_link.attr('href'),
      data: { status: $subscription_link.data('subscribe') },
      success: function (data) {
        $subscribe_notification.html(data.res);
      },
      error: function (data) {
        $subscribe_notification.text(data.res);
      }
    });
    return false;
  })
})
