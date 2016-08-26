import postgres

class Time(postgres.ToolTypeMixin, postgres.Base):

    __tablename__ = 'mutect2_vc_cwl_metrics'
