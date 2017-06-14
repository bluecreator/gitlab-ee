import AccessorUtilities from '~/lib/utils/accessor';

import '~/signin_tabs_memoizer';

((global) => {
  describe('SigninTabsMemoizer', () => {
    const fixtureTemplate = 'static/signin_tabs.html.raw';
    const tabSelector = 'ul.nav-tabs';
    const currentTabKey = 'current_signin_tab';
    let memo;

    function createMemoizer() {
      memo = new global.ActiveTabMemoizer({
        currentTabKey,
        tabSelector,
      });
      return memo;
    }

    preloadFixtures(fixtureTemplate);

    beforeEach(() => {
      loadFixtures(fixtureTemplate);

      spyOn(AccessorUtilities, 'isLocalStorageAccessSafe').and.returnValue(true);
    });

    it('does nothing if no tab was previously selected', () => {
      createMemoizer();

      expect(document.querySelector('li a.active').getAttribute('id')).toEqual('standard');
    });

    it('shows last selected tab on boot', () => {
      createMemoizer().saveData('#ldap');
      const fakeTab = {
        click: () => {},
      };
      spyOn(document, 'querySelector').and.returnValue(fakeTab);
      spyOn(fakeTab, 'click');

      memo.bootstrap();

      // verify that triggers click on the last selected tab
      expect(document.querySelector).toHaveBeenCalledWith(`${tabSelector} a[href="#ldap"]`);
      expect(fakeTab.click).toHaveBeenCalled();
    });

    it('saves last selected tab on change', () => {
      createMemoizer();

      document.getElementById('standard').click();

      expect(memo.readData()).toEqual('#standard');
    });

    describe('class constructor', () => {
      beforeEach(() => {
        memo = createMemoizer();
      });

      it('should set .isLocalStorageAvailable', () => {
        expect(AccessorUtilities.isLocalStorageAccessSafe).toHaveBeenCalled();
        expect(memo.isLocalStorageAvailable).toBe(true);
      });
    });

    describe('saveData', () => {
      beforeEach(() => {
        memo = {
          currentTabKey,
        };

        spyOn(localStorage, 'setItem');
      });

      describe('if .isLocalStorageAvailable is `false`', () => {
        beforeEach(function () {
          memo.isLocalStorageAvailable = false;

          global.ActiveTabMemoizer.prototype.saveData.call(memo);
        });

        it('should not call .setItem', () => {
          expect(localStorage.setItem).not.toHaveBeenCalled();
        });
      });

      describe('if .isLocalStorageAvailable is `true`', () => {
        const value = 'value';

        beforeEach(function () {
          memo.isLocalStorageAvailable = true;

          global.ActiveTabMemoizer.prototype.saveData.call(memo, value);
        });

        it('should call .setItem', () => {
          expect(localStorage.setItem).toHaveBeenCalledWith(currentTabKey, value);
        });
      });
    });

    describe('readData', () => {
      const itemValue = 'itemValue';
      let readData;

      beforeEach(() => {
        memo = {
          currentTabKey,
        };

        spyOn(localStorage, 'getItem').and.returnValue(itemValue);
      });

      describe('if .isLocalStorageAvailable is `false`', () => {
        beforeEach(function () {
          memo.isLocalStorageAvailable = false;

          readData = global.ActiveTabMemoizer.prototype.readData.call(memo);
        });

        it('should not call .getItem and should return `null`', () => {
          expect(localStorage.getItem).not.toHaveBeenCalled();
          expect(readData).toBe(null);
        });
      });

      describe('if .isLocalStorageAvailable is `true`', () => {
        beforeEach(function () {
          memo.isLocalStorageAvailable = true;

          readData = global.ActiveTabMemoizer.prototype.readData.call(memo);
        });

        it('should call .getItem and return the localStorage value', () => {
          expect(window.localStorage.getItem).toHaveBeenCalledWith(currentTabKey);
          expect(readData).toBe(itemValue);
        });
      });
    });
  });
})(window);
