describe('MRAID', function() {
  var MRAID, BRIDGE;

  beforeEach(function() {
    MRAID = mraid;
    BRIDGE = mraidbridge;
  });
  
  describe('.removeEventListener', function() {
    var funcSpy;
    var errorSpy;
    
    beforeEach(function () {
      funcSpy = jasmine.createSpy();
      MRAID.addEventListener(MRAID.EVENTS.VIEWABLECHANGE, funcSpy);
      
      errorSpy = jasmine.createSpy();
      MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
    });
    
    afterEach(function () {
      MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE);
      MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
    });
    
    it('should remove the listener passed in', function() {
      MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE, funcSpy);
      BRIDGE.fireChangeEvent({viewable: true});
      expect(funcSpy).toHaveNotBeenCalled;    
    });
    
    it("should remove the only listener when we don't specify a listener", function() {
      MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE);
      BRIDGE.fireChangeEvent({viewable: true});
      expect(funcSpy).toHaveNotBeenCalled;  
    });
    
    it('should not do anything when we remove a listener that was never added', function(){
      var bogusFunc = function (e) {var huh = "idontknow";};
      MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE, bogusFunc);
      BRIDGE.fireChangeEvent({viewable: true});  
      expect(funcSpy).toHaveBeenCalled;         
    });
    
    it('should produce an error when no recognizable event is passed in', function() {
      MRAID.removeEventListener('hotdogsdfasdfasdfsdfsdfsdfsfsf', funcSpy);
      expect(errorSpy).toHaveBeenCalled
    });

    it('should produce an error when passing in a listener that does not belong to the event', function() {
      var bogusFunc = function(e) {var huh = "idontknow";};
      MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE, bogusFunc);
      expect(errorSpy).toHaveBeenCalled
    });

    it('should produce an error when nothing is passed in', function() {
      MRAID.removeEventListener();
      expect(errorSpy).toHaveBeenCalled
    }); 

    describe('when there are multiple event listeners for one event', function() {
      var spy1;
      var spy2;
      var spy3; 
        
      beforeEach(function() {
        spy1 = jasmine.createSpy();
        spy2 = jasmine.createSpy();
        spy3 = jasmine.createSpy();
        MRAID.addEventListener(MRAID.EVENTS.VIEWABLECHANGE, spy1);
        MRAID.addEventListener(MRAID.EVENTS.VIEWABLECHANGE, spy2);
        MRAID.addEventListener(MRAID.EVENTS.VIEWABLECHANGE, spy3);
      });
      
      it('should remove all listeners when no listener is passed in for the event', function() {
        MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE);
        BRIDGE.fireChangeEvent({viewable: true});  
        expect(spy1).toHaveNotBeenCalled;
        expect(spy2).toHaveNotBeenCalled;
        expect(spy3).toHaveNotBeenCalled;     
      });
      
      it('should not do anything when we remove a listener that was never added', function(){
        var bogusFunc = function (e) {var huh = "idontknow";};
        MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE, bogusFunc);
        BRIDGE.fireChangeEvent({viewable: true});  
        expect(spy1).toHaveBeenCalled;     
        expect(spy2).toHaveBeenCalled;
        expect(spy3).toHaveBeenCalled;     
      });
      
      it('should only remove the listener passed in', function() {
        // x and z should change, but y should not since we removed the function that modifies y.
        MRAID.removeEventListener(MRAID.EVENTS.VIEWABLECHANGE, spy2);
        BRIDGE.fireChangeEvent({viewable: true});
        expect(spy1).toHaveBeenCalled;     
        expect(spy2).toHaveNotBeenCalled;
        expect(spy3).toHaveBeenCalled;
      });
      
      it('should not affect any listeners when nothing is passed in', function() {
        MRAID.removeEventListener();
        BRIDGE.fireChangeEvent({viewable: true});  
        expect(spy1).toHaveBeenCalled;     
        expect(spy2).toHaveBeenCalled;
        expect(spy3).toHaveBeenCalled; 
      });
    });
  });
  
  describe('.supports', function() {
    describe('when called with a feature parameter', function() {
      var result;

      beforeEach(function() {
        expect(MRAID.supports('sms')).toEqual(false);
        BRIDGE.fireChangeEvent({supports: {'sms': true}});
        result = MRAID.supports('sms');
      });

      it('gets the correct value', function() {
        expect(result).toEqual(true);
      });
    });
  });

  describe('.playVideo', function() {
    describe('when called when the ad is not viewable', function() {
      beforeEach(function() {
        BRIDGE.fireChangeEvent({viewable: false});
        spyOn(BRIDGE, 'executeNativeCall');
        errorSpy = jasmine.createSpy();
        MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
        MRAID.playVideo("http://early.bird");
      });

      afterEach(function() {
        MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
      });

      it('does not execute native call and an error is fired', function() {
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'playVideo');
      });
    });

    describe('when called incorrectly and the ad is viewable', function() {
      var errorSpy;

      beforeEach(function() {
        BRIDGE.fireChangeEvent({viewable: true});
        spyOn(BRIDGE, 'executeNativeCall');
        errorSpy = jasmine.createSpy();
        MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
        MRAID.playVideo(); // should've used a URL
      });

      afterEach(function() {
        MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
      });

      it('does not execute native call and an error is fired', function() {
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'playVideo')
      });
    });

    describe('when called correctly and the ad is viewable', function() {
      beforeEach(function() {
        BRIDGE.fireChangeEvent({viewable: true});
        spyOn(BRIDGE, 'executeNativeCall');
        MRAID.playVideo('http://www.youtube.com/watch?v=nGYVjRrBhWo');
      });

      it('tells the SDK to play a video with the url', function() {
        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
          'playVideo',
          'uri',
          'http://www.youtube.com/watch?v=nGYVjRrBhWo'
        );
      });
    });
  });

  describe('.storePicture', function() {
    describe('when called when the ad is not viewable', function() {
      beforeEach(function() {
        BRIDGE.fireChangeEvent({viewable: false});
        spyOn(BRIDGE, 'executeNativeCall');
        errorSpy = jasmine.createSpy();
        MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
        MRAID.storePicture("http://dummyimage.com/600x400/000/fff");
      });

      afterEach(function() {
        MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
      });

      it('does not execute native call and an error is fired', function() {
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'storePicture')
      });
    });

    describe('when called incorrectly and the ad is viewable', function() {
      var errorSpy;

      beforeEach(function() {
        BRIDGE.fireChangeEvent({viewable: true});
        spyOn(BRIDGE, 'executeNativeCall');
        errorSpy = jasmine.createSpy();
        MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
        MRAID.storePicture() // shoul've used a URI
      });

      afterEach(function() {
        MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
      });

      it('does not execute native call and an error is fired', function() {
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'storePicture')
      });
    })

    describe('when called correctly and the ad is viewable', function() {
      beforeEach(function() {
        BRIDGE.fireChangeEvent({viewable: true});
        spyOn(BRIDGE, 'executeNativeCall');
        MRAID.storePicture("http://dummyimage.com/600x400/000/fff");
      });

      it('tells the SDK to store a picture with the url', function() {
        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
         'storePicture',
          'uri',
          'http://dummyimage.com/600x400/000/fff'
        );
      });
    });

  });


  describe('.expand', function() {
    describe('when called in default state', function() {
      beforeEach(function() {
        spyOn(MRAID, 'getState').andReturn('default');
        spyOn(BRIDGE, 'executeNativeCall');
        MRAID.expand();
      });

      it('applies args to bridge correctly', function() {
        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith('expand', 'lockOrientation', false);
      });
    });

    describe('when called with default state and custom params', function() {
      beforeEach(function() {
        MRAID.setExpandProperties({
          useCustomClose: true
        });
        spyOn(MRAID, 'getState').andReturn('default');
        spyOn(MRAID, 'getHasSetCustomClose').andReturn(true);
        spyOn(MRAID, 'getHasSetCustomSize').andReturn(true);
        spyOn(BRIDGE, 'executeNativeCall');
        MRAID.expand();
      });

      it('applies args to bridge correctly', function() {
        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
          'expand', 'shouldUseCustomClose', 'true', 'lockOrientation', false
        );
      });
    });

    describe('when called with default state and url', function() {
      beforeEach(function() {
        MRAID.setExpandProperties({
          useCustomClose: false
        });
        spyOn(MRAID, 'getState').andReturn('default');
        spyOn(BRIDGE, 'executeNativeCall');
        MRAID.expand('http://url.com');
      });

      it('applies args to bridge correctly', function() {
        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
          'expand', 'shouldUseCustomClose', 'false', 'lockOrientation', false, 'url', 'http://url.com'
        );
      });
    });
  });

  describe('.createCalendarEvent', function() {
    describe('when called incorrectly', function() {
      var errorSpy;

      beforeEach(function() {
        spyOn(BRIDGE, 'executeNativeCall');
        errorSpy = jasmine.createSpy();
        MRAID.addEventListener(MRAID.EVENTS.ERROR, errorSpy);
      });

      afterEach(function() {
        MRAID.removeEventListener(MRAID.EVENTS.ERROR, errorSpy);
      });

      it('does not allow a calendar event with a null property dictionary', function() {
        MRAID.createCalendarEvent(null);
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });

      //it('calendar event with invalid start and end time values', function() {
      //  MRAID.createCalendarEvent({description:'bad day', start: 'totally incorrect', end: '20001 space time'});
      //  expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
      //  expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      //});

      //it('should not allow a calendar event with an entirely bogus reminder field', function() {
      //  MRAID.createCalendarEvent({reminder: 'entirely_bogus'});
      //  expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
      //  expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      //});

      //it('should not allow a calendar event with a relative reminder whose date is after the event has started', function() {
      //  MRAID.createCalendarEvent({reminder: '6000000'}); // Attempted reminder for 10m after start
      //  expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
      //  expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      //});

      it('does not allow a calendar event with an invalid recurrence interval', function() {
        MRAID.createCalendarEvent({recurrence: {interval: null}});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });

      it('should not allow a calendar event with an invalid recurrence frequency', function() {
        MRAID.createCalendarEvent({recurrence: {frequency: 'aBsuRd value!'}});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      })

      it('should not allow a calendar event with a null recurrence days of the week', function() {
        MRAID.createCalendarEvent({recurrence: {daysInWeek: null}});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });

      it('should not allow a calendar event with a null recurrence days of the month', function() {
        MRAID.createCalendarEvent({recurrence: {daysInMonth: null}});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });

      it('should not allow a calendar event with a null recurrence days of the year', function() {
        MRAID.createCalendarEvent({recurrence: {daysInYear: null}});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });

      it('should not allow a calendar event with a null recurrence months of the year', function() {
        MRAID.createCalendarEvent({recurrence: {monthsInYear: null}});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });

      it('should not allow a calendar event with an invalid transparency setting', function() {
        MRAID.createCalendarEvent({transparency: 'bogus'});
        expect(BRIDGE.executeNativeCall).not.toHaveBeenCalled();
        expect(errorSpy).toHaveBeenCalledWith(jasmine.any(String), 'createCalendarEvent');
      });
    });

    describe('when called correctly', function() {
      beforeEach(function() {
        spyOn(BRIDGE, 'executeNativeCall');
      });

      it('allows a calendar event with an empty property dictionary', function() {
        MRAID.createCalendarEvent({});
        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith('createCalendarEvent');
      });

      it('allows a calendar event with basic parameters (description, start, end, location, summary)', function() {
        MRAID.createCalendarEvent({
          description: 'Mayan Apocalypse/End of World',
          start: '2113-07-19T20:00:00-04:00',
          end: '2113-07-19T21:00:00-04:00',
          location: 'Tikal, Guatemala',
          summary: 'You are going to have a bad time'
        });

        expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
          'createCalendarEvent',
          'description', 'Mayan Apocalypse/End of World',
          'location', 'Tikal, Guatemala',
          'summary', 'You are going to have a bad time',
          'start', '2113-07-19T20:00:00-04:00',
          'end', '2113-07-19T21:00:00-04:00'
        );
      });

      describe('events with reminders', function() {
        it('allows a calendar event with an absolute reminder', function() {
          MRAID.createCalendarEvent({reminder: '2113-07-19T19:50:00-04:00'}); // 10m before start
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'absoluteReminder', '2113-07-19T19:50:00-04:00');
        });

        it('allows a calendar event with an negative relative reminder', function() {
          MRAID.createCalendarEvent({reminder: '-600000'}); // 10m before start
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'relativeReminder', -600);
        });
      });

      describe('recurring events', function() {
        it('should allow a calendar event with a valid recurrence interval', function() {
          MRAID.createCalendarEvent({
            recurrence: {interval: 2}
          });
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 2);
        });

        it('should use a default value of 1 for recurrence interval when no interval is sent', function() {
          MRAID.createCalendarEvent({
            recurrence: {}
          });
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 1);
        });

        it('should allow a calendar event with a valid recurrence frequency', function() {
          var validFrequencies = ['daily', 'weekly', 'monthly', 'yearly'];
          for (var i = 0; i < validFrequencies.length; i++) {
            var currentFrequency = validFrequencies[i];
            MRAID.createCalendarEvent({recurrence: {frequency: currentFrequency}});
            expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
              'createCalendarEvent',
              'interval', 1,
              'frequency', currentFrequency);
          }
        });

        it('should allow a calendar event that repeats up until a certain recurrence end date', function() {
          MRAID.createCalendarEvent({
            recurrence: {frequency: 'weekly', interval: 2, expires: '2114-07-19T20:00:00-04:00'} // recurrence ends 1 year later
          });
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 2,
            'frequency', 'weekly',
            'expires', '2114-07-19T20:00:00-04:00');
        });

        it('should allow a calendar event that repeats forever', function() {
          MRAID.createCalendarEvent({
            recurrence: {frequency: 'weekly', interval: 2, expires: null}
          });
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 2,
            'frequency', 'weekly');
        });

        it('should allow a calendar event that repeats for given days of the week', function() {
          MRAID.createCalendarEvent({recurrence: {daysInWeek: [1,2]}});
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 1,
            'daysInWeek', '1,2'
          )
        });

        it('should allow a calendar event that repeats for given days of the month', function() {
          MRAID.createCalendarEvent({recurrence: {daysInMonth: [1,2]}});
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 1,
            'daysInMonth', '1,2'
          )
        });

        it('should allow a calendar event that repeats for given days of the year', function() {
          MRAID.createCalendarEvent({recurrence: {daysInYear: [1,2]}});
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 1,
            'daysInYear', '1,2'
          )
        });

        it('should allow a calendar event that repeats for given months of the year', function() {
          MRAID.createCalendarEvent({recurrence: {monthsInYear: [1,2]}});
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'interval', 1,
            'monthsInYear', '1,2'
          )
        });
      });

      describe('events with transparency', function() {
        it('should allow a calendar event to mark the participant as busy during the event', function() {
          MRAID.createCalendarEvent({transparency: 'opaque'}); // 'opaque' means busy
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'transparency', 'opaque'
          );
        });

        it('should allow a calendar event to mark the participant as free during the event', function() {
          MRAID.createCalendarEvent({transparency: 'transparent'}); // 'transparent' means free
          expect(BRIDGE.executeNativeCall).toHaveBeenCalledWith(
            'createCalendarEvent',
            'transparency', 'transparent'
          );
        });
      });
    });
  });
});
