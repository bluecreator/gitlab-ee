import CEMergeRequestStore from '../../stores/mr_widget_store';

export default class MergeRequestStore extends CEMergeRequestStore {
  setData(data) {
    super.setData(data);
    this.initGeo(data);
    this.initSquashBeforeMerge();
    this.initApprovals(data);
  }

  initSquashBeforeMerge() {
    this.enableSquashBeforeMerge = true;
  }

  initGeo(data) {
    this.is_geo_secondary_node = data.is_geo_secondary_node;
  }

  initApprovals(data) {
    this.approvals = this.approvals || null;
    this.approvalsPath = data.approvals_path || this.approvalsPath;
    this.approvalsRequired = !!data.approvals_required;
  }

  setApprovals(data) {
    this.approvals = data;
    this.approvalsLeft = !!data.approvals_left;
    this.isFrozen = this.approvalsRequired && this.approvalsLeft;
  }
}
