from sqlalchemy import create_engine, MetaData, Table
from sqlalchemy.engine.url import URL
from sqlalchemy import Column, Integer, String, Float, cast
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, mapper
from sqlalchemy.engine.reflection import Inspector
from sqlalchemy import exc
from sqlalchemy.dialects.postgresql import ARRAY
from contextlib import contextmanager
from sqlalchemy.sql import select

Base = declarative_base()

class ToolTypeMixin(object):
    """ Gather information about processing status """

    id = Column(Integer, primary_key=True)
    case_id = Column(String)
    vcf_id = Column(String)
    files = Column(ARRAY(String))
    status = Column(String)
    location = Column(String)

    def __repr__(self):
        return "<ToolTypeMixin(case_id='%s', status='%s' , location='%s'>" %(self.case_id,
                self.status, self.location)

class MuTect(ToolTypeMixin, Base):

    __tablename__ = 'mutect2_vc_status'


def db_connect(database):
    """performs database connection"""

    return create_engine(URL(**database))

def create_table(engine, tool):
    """ checks if a table  exists and create one if it doesn't """

    inspector = Inspector.from_engine(engine)
    tables = set(inspector.get_table_names())
    if tool.__tablename__ not in tables:
        Base.metadata.create_all(engine)

def add_status(engine, case_id, vcf_id, file_ids, status, output_location):
    """ add provided metrics to database """

    Session = sessionmaker()
    Session.configure(bind=engine)
    session = Session()

    met = MuTect(case_id = case_id,
                 vcf_id = vcf_id,
                 files = file_ids,
                 status = status,
                 location = output_location)

    create_table(engine, met)
    session.add(met)
    session.commit()
    session.close()

class State(object):
    pass

class Files(object):
    pass


def get_case(engine, status_table):

    Session = sessionmaker()
    Session.configure(bind=engine)
    session = Session()

    meta = MetaData(engine)

    #read the status table
    state = Table(status_table, meta, autoload=True)

    mapper(State, state)

    data = Table('wxs_tn_match_for_vc', meta,
                 Column("tumor_gdc_id", String, primary_key=True),
                 Column("normal_gdc_id", String, primary_key=True),
                 autoload=True)

    mapper(Files, data)
    count = 0
    s = dict()

    cases = session.query(Files).all()

    for row in cases:

        tnpair = [row.normal_gdc_id, row.tumor_gdc_id]

        completion = session.query(State).filter(State.files == cast(tnpair, ARRAY(String))).all()

        rexecute = True

        for comp_case in completion:

            if not comp_case == None:
                if comp_case.status == 'COMPLETED':
                    rexecute = False

        if rexecute:

            s[count] = [row.case_id,
                        row.normal_gdc_id,
                        row.normal_s3_url,
                        row.tumor_gdc_id,
                        row.tumor_s3_url]
            count += 1

    return s
