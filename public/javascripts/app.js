function init(){
  $('form').keyup(calculate);
  $('.slider').each(function() {
                      var self = $(this);
                      self.slider({
                                    orientation: 'vertical',
                                    step: 1,
                                    max: 10,
                                    min: 1,
                                    slide: function( event, ui) {
                                      self.parent().find('input').val(ui.value);
                                    },
                                    stop: calculate
                                     });
                    });
}
$(document).ready(init);

function calculate(){
  $.ajax({
           type: 'post',
           url: '/calculate',
           data: $('form').serialize(),
           dataType: 'json',
           success: function(data){
             $('#one_chance_to_win').html(data['attacker']);
             $('#two_chance_to_win').html(data['defender']);
         }});
}