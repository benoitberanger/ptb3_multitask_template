function result = Initialize()
logger = getLogger();

logger.log('Try to connect with the Eyelink ...')

status = Eyelink('Initialize');
switch status
    case 0
        logger.ok ('Eyelink initialization status : OK')
        result = true;
    otherwise
        logger.err('Eyelink initialization status : error %d',status)
        result = false;
end

end % fcn
