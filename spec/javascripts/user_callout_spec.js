/* esint-disable space-before-function-paren, arrow-body-style */
const UserCallout = require('~/user_callout');

const USER_CALLOUT_COOKIE = 'user_callout_dismissed';
const Cookie = window.Cookies;

describe('UserCallout', function () {
  const fixtureName = 'static/user_callout.html.raw';
  preloadFixtures(fixtureName);

  beforeEach(() => {
    loadFixtures(fixtureName);
    this.userCallout = new UserCallout();
    this.dismissIcon = $('.dismiss-icon');
    this.userCalloutContainer = $('.user-callout');
    this.userCalloutBtn = $('.user-callout-btn');
    Cookie.set(USER_CALLOUT_COOKIE, 0);
  });

  it('shows when cookie is set to false', () => {
    expect(Cookie.get(USER_CALLOUT_COOKIE)).toBeDefined();
    expect(this.userCalloutContainer.is(':visible')).toBe(true);
  });

  it('hides when user clicks on the dismiss-icon', () => {
    this.dismissIcon.click();
    expect(this.userCalloutContainer.is(':visible')).toBe(false);
    expect(Cookie.get(USER_CALLOUT_COOKIE)).toBe('1');
  });

  it('hides when user clicks on the "check it out" button', () => {
    this.userCalloutBtn.click();
    expect(this.userCalloutContainer.is(':visible')).toBe(false);
    expect(Cookie.get(USER_CALLOUT_COOKIE)).toBe('1');
  });
});
