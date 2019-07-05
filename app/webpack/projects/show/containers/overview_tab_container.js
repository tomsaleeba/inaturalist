import { connect } from "react-redux";
import OverviewTab from "../components/overview_tab";
import { setSelectedTab } from "../ducks/project";
import { updateCurrentUser } from "../../../shared/ducks/config";

function mapStateToProps( state ) {
  return {
    config: state.config,
    project: state.project
  };
}

function mapDispatchToProps( dispatch ) {
  return {
    setSelectedTab: tab => dispatch( setSelectedTab( tab ) ),
    updateCurrentUser: user => dispatch( updateCurrentUser( user ) )
  };
}

const OverviewTabContainer = connect(
  mapStateToProps,
  mapDispatchToProps
)( OverviewTab );

export default OverviewTabContainer;
