alter table metrics add column description text;
update metrics set description = 'The visual appeal and beauty of the landscape.' where key = 'landscape_beauty';
update metrics set description = 'How distinctive and unique the park is compared to other natural areas.' where key = 'uniqueness';
update metrics set description = 'The frequency and quality of memorable, awe-inspiring moments.' where key = 'wow_moments';
update metrics set description = 'The level of visitor density and crowding.' where key = 'crowds';
update metrics set description = 'The diversity and abundance of wildlife observed.' where key = 'wildlife';
update metrics set description = 'The diversity of landscapes and experiences available.' where key = 'variety';
update metrics set description = 'The quantity and quality of different park activities and attractions.' where key = 'selection';
update metrics set description = 'The ease of reaching the park and key locations.' where key = 'access';
