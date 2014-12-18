//= require jquery
//= require bootstrap
//= require_tree .

$( function() {
  $(window).resize(set_data_offset);
  set_data_offset();
});

var set_data_offset = function() {
  $("[data-offset-top]").each( function( e ) {
    $(this).attr( "data-offset-top", $(".shoutout").height() );
  })
}
