export function resolve(loader, key, referer) { return key; }

export function fetch(loader, key) {
  let imageName = key.replace(/^@.*\//, '');
  let image = UIImage.imageNamed(imageName);
  if (!image) {
    throw new Error(`Could not find image ${imageName}.`);
  }
  return Promise.resolve(image);
}

export function translate(loader, key, image) { return image; }

export function instantiate(loader, key, image) {
  return loader.createSyntheticModule(key, {default : image});
}

export function evaluate(loader, key, module) {
  // don't pass key to avoid infinite recursion and stack overflow
  return loader.evaluate(undefined, module);
}