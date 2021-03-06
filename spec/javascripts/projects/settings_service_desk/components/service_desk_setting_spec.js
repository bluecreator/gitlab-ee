import Vue from 'vue';
import eventHub from '~/projects/settings_service_desk/event_hub';
import serviceDeskSetting from '~/projects/settings_service_desk/components/service_desk_setting.vue';

describe('ServiceDeskSetting', () => {
  let ServiceDeskSetting;
  let vm;

  beforeEach(() => {
    ServiceDeskSetting = Vue.extend(serviceDeskSetting);
  });

  afterEach(() => {
    if (vm) {
      vm.$destroy();
    }
  });

  describe('when isEnabled=true', () => {
    describe('only isEnabled', () => {
      describe('as project admin', () => {
        beforeEach(() => {
          vm = new ServiceDeskSetting({
            propsData: {
              isEnabled: true,
            },
          }).$mount();
        });

        it('should see activation checkbox (not disabled)', () => {
          expect(vm.$refs['enabled-checkbox'].getAttribute('disabled')).toEqual(null);
        });

        it('should see main panel with the email info', () => {
          expect(vm.$el.querySelector('.panel')).toBeDefined();
        });

        it('should see loading spinner', () => {
          expect(vm.$el.querySelector('.fa-spinner')).toBeDefined();
          expect(vm.$el.querySelector('.fa-exclamation-circle')).toBeNull();
          expect(vm.$refs['service-desk-incoming-email']).toBeUndefined();
        });
      });
    });

    describe('with incomingEmail', () => {
      beforeEach(() => {
        vm = new ServiceDeskSetting({
          propsData: {
            isEnabled: true,
            incomingEmail: 'foo@bar.com',
          },
        }).$mount();
      });

      it('should see email', () => {
        expect(vm.$refs['service-desk-incoming-email'].textContent.trim()).toEqual('foo@bar.com');
        expect(vm.$el.querySelector('.fa-spinner')).toBeNull();
        expect(vm.$el.querySelector('.fa-exclamation-circle')).toBeNull();
      });
    });
  });

  describe('when isEnabled=false', () => {
    beforeEach(() => {
      vm = new ServiceDeskSetting({
        propsData: {
          isEnabled: false,
        },
      }).$mount();
    });

    it('should not see panel', () => {
      expect(vm.$el.querySelector('.panel')).toBeNull();
    });

    it('should not see warning message', () => {
      expect(vm.$refs['recommend-protect-email-from-spam-message']).toBeUndefined();
    });
  });

  describe('methods', () => {
    describe('onCheckboxToggle', () => {
      let onCheckboxToggleSpy;

      beforeEach(() => {
        onCheckboxToggleSpy = jasmine.createSpy('spy');
        eventHub.$on('serviceDeskEnabledCheckboxToggled', onCheckboxToggleSpy);

        vm = new ServiceDeskSetting({
          propsData: {
            isEnabled: false,
          },
        }).$mount();
      });

      afterEach(() => {
        eventHub.$off('serviceDeskEnabledCheckboxToggled', onCheckboxToggleSpy);
      });

      it('when getting checked', () => {
        expect(onCheckboxToggleSpy).not.toHaveBeenCalled();
        vm.onCheckboxToggle({
          target: {
            checked: true,
          },
        });
        expect(onCheckboxToggleSpy).toHaveBeenCalledWith(true);
      });

      it('when getting unchecked', () => {
        expect(onCheckboxToggleSpy).not.toHaveBeenCalled();
        vm.onCheckboxToggle({
          target: {
            checked: false,
          },
        });
        expect(onCheckboxToggleSpy).toHaveBeenCalledWith(false);
      });
    });
  });
});
