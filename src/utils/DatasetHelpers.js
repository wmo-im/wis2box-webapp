export function createTopicList(datasets) {
  if (datasets) {
    let topics = [];
    datasets.forEach((dataset) => {
      topics = topics.concat(dataset.metadata.topic);
    });
    return topics;
  }
}