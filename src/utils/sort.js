function quickSort(arr, low = 0, high = arr.length - 1, prop) {
  if (low < high) {
    const pivotIndex = partition(arr, low, high, prop);
    quickSort(arr, low, pivotIndex - 1, prop);
    quickSort(arr, pivotIndex + 1, high, prop);
  }
  return arr;
}

function partition(arr, low, high, prop) {
  const pivot = prop ? arr[high][prop] : arr[high];
  let i = low - 1;
  for (let j = low; j <= high - 1; j++) {
    if ((prop ? arr[j][prop] : arr[j]) <= pivot) {
      i++;
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
  }
  [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
  return i + 1;
}

export { quickSort };
