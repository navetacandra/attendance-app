function addInstance(req, _, next, { instance, name }) {
  req[name] = instance;
  next();
}

export { addInstance as default };
