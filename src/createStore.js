import {compose, createStore, applyMiddleware} from 'redux';
import thunk from 'redux-thunk';

import rootReducer from './reducers';
import hearingEditorMiddleware from './middleware/hearingEditor';

import identity from 'lodash/identity';
import {routerMiddleware} from 'react-router-redux';
import createBrowserHistory from 'history/createBrowserHistory';
import config from './config';
import RavenMiddleWare from 'redux-raven-middleware';

export const history = createBrowserHistory();
const middleware = [RavenMiddleWare(config.uiConfig.sentryDns), thunk, routerMiddleware(history), ...hearingEditorMiddleware];

if (typeof window !== 'undefined' && process.env.NODE_ENV !== 'production' && process.env.NODE_ENV !== 'test') {
  middleware.push(require('redux-logger')());
}

export default function createAppStore(initialState = null) {
  // Have to pass in the router to support isomorphic rendering
  const augmentedCreateStore = compose(
    applyMiddleware(...middleware),
    typeof window !== 'undefined' && window.devToolsExtension ? window.devToolsExtension() : identity,
  )(createStore);
  return augmentedCreateStore(rootReducer, initialState || {});
}
